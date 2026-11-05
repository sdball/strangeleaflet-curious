// Runs the Z-Machine Interpreter page's engine in Node, for checking it
// against dfrotz. Not published; nothing on the site uses this.
//
//   node stories/play.mjs story.z3 [commands.txt] [--seed N] [--width 80] [--no-echo] [--files]
//
// Prints the transcript: what the game printed, with each command after
// its prompt. With --no-echo the commands are left out, and so is the line
// break after them, which is how dfrotz prints a game played from a file.
// With no commands file, it reads commands from stdin. With --files, save
// and restore take the next command as a file name and write or read a
// Quetzal file there, as dfrotz does; without it they keep one save in memory.
import fs from "node:fs";
import vm from "node:vm";
import path from "node:path";

const here = path.dirname(new URL(import.meta.url).pathname);
const page = fs.readFileSync(path.join(here, "../public/z-machine-interpreter/index.html"), "utf8");
const script = page.slice(page.indexOf("// ---------- Story file ----------"), page.indexOf("// ---------- Page ----------"));

const args = process.argv.slice(2);
const opt = (name, dflt) => { const i = args.indexOf(name); if (i < 0) return dflt; const v = args[i + 1]; args.splice(i, 2); return v; };
const seed = Number(opt("--seed", "12345"));
const width = Number(opt("--width", "80"));
const noEcho = args.includes("--no-echo");
if (noEcho) args.splice(args.indexOf("--no-echo"), 1);
const files = args.includes("--files");
if (files) args.splice(args.indexOf("--files"), 1);
const [storyPath, cmdPath] = args;
const commands = fs.readFileSync(cmdPath || 0, "utf8").split("\n");
if (commands[commands.length - 1] === "") commands.pop();

const ctx = vm.createContext({ TextDecoder, TextEncoder, btoa, atob, Math, performance, console });
vm.runInContext(script + `
;globalThis.api = { unwrap, readStory, makeMachine, runSlice, finishLine, finishChar, answer, SCREEN, snapshot, applySnapshot, packSnap, unpackSnap, decodeAt, toQuetzal, fromQuetzal };`, ctx);
const api = ctx.api;
api.SCREEN.width = width;

const w = api.unwrap(fs.readFileSync(storyPath));
const pristine = w.bytes.slice();
const s = api.readStory(new Uint8Array(pristine));
const m = api.makeMachine(s, pristine, seed);

let out = "", printed = 0, saved = null, clears = m.clears;
const take = () => {
  if (m.clears !== clears) { clears = m.clears; printed = 0; }
  // everything printed since last time, as plain text
  const text = m.lines.map((l) => l.map((r) => r.t).join("")).join("\n");
  const all = text;
  const fresh = all.slice(printed);
  printed = all.length;
  return fresh;
};
let k = 0, guard = 0;
while (guard++ < 100000) {
  api.runSlice(m, 5_000_000);
  out += take();
  const why = m.halted?.why;
  if (why === "input") {
    if (k >= commands.length) break;
    const c = commands[k++];
    if (!noEcho) {
      m.lines[m.lines.length - 1].push({ t: c, s: 16 });
      m.lines.push([]);
      out += take();
    }
    api.finishLine(m, c);
  } else if (why === "char") {
    if (k >= commands.length) break;
    const c = commands[k++];
    api.finishChar(m, c ? c.charCodeAt(0) : 13);
  } else if (why === "save") {
    saved = api.packSnap(m, Object.assign(api.snapshot(m), { waiting: null, after: m.waiting.ins.addr }));
    const ins = m.waiting.ins;
    m.waiting = null; m.halted = null;
    if (files) fs.writeFileSync(commands[k++], api.toQuetzal(m, saved));
    api.answer(m, ins, 1);
  } else if (why === "restore") {
    const ins = m.waiting.ins;
    m.waiting = null; m.halted = null;
    if (files) {
      try { saved = api.fromQuetzal(m, fs.readFileSync(commands[k++])).data; }
      catch (err) { saved = null; out += `\n[restore failed: ${err.message}]\n`; }
    }
    if (saved) { api.applySnapshot(m, api.unpackSnap(m, saved)); api.answer(m, api.decodeAt(s, saved.after), 2); }
    else api.answer(m, ins, 0);
  } else if (why === "quit") break;
  else { out += `\n[halted: ${why} ${m.halted?.text || ""}]\n`; break; }
  // keep memory of printed text bounded on long runs
  if (m.lines.length > 2000) { m.lines.splice(0, m.lines.length - 1); printed = m.lines[0].map((r) => r.t).join("").length; }
}
process.stdout.write(out + "\n");
process.stderr.write(`[${m.count} instructions]\n`);
