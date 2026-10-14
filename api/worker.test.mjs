// Run with: node --test api/worker.test.mjs
// Stands in for the Internet Archive and Cloudflare's cache, so nothing leaves the machine.

import { test, beforeEach, afterEach } from "node:test";
import assert from "node:assert/strict";

const TSV =
  "date_time_(UTC)\tchannel\tduration\thttps://archive.org/details/\ttext\n" +
  "2026-10-14 13:42:00\tCNNW\t55\tCNNW_20261014_130000_CNN_News_Central/start/2520\tTHE ODDS\n";

let now, calls, answer, edgeStore, worker;
const realFetch = globalThis.fetch;
const realNow = Date.now;
let fresh = 0;

// each test gets a new module, like a new isolate with empty memory
async function newIsolate() {
  worker = (await import(`./worker.js?isolate=${++fresh}`)).default;
}

// Cloudflare's cache, honoring s-maxage against the fake clock
const fakeEdge = {
  async match(req) {
    const kept = edgeStore.get(req.url);
    return kept && now < kept.expires ? new Response(kept.body) : undefined;
  },
  async put(req, res) {
    const seconds = Number(res.headers.get("cache-control").match(/s-maxage=(\d+)/)[1]);
    edgeStore.set(req.url, { body: await res.text(), expires: now + seconds * 1000 });
  },
};

const ctx = { waitUntil: (p) => p };

async function get(path, init) {
  const res = await worker.fetch(new Request(`https://curious-api.example.workers.dev${path}`, init), {}, ctx);
  await new Promise((r) => setTimeout(r)); // let waitUntil puts settle
  return res;
}

beforeEach(async () => {
  now = Date.parse("2026-10-14T14:00:00Z");
  Date.now = () => now;
  calls = [];
  answer = () => new Response(TSV);
  edgeStore = new Map();
  globalThis.caches = { default: fakeEdge };
  globalThis.fetch = async (url, init) => {
    calls.push({ url: String(url), init });
    return answer();
  };
  await newIsolate();
});

afterEach(() => {
  globalThis.fetch = realFetch;
  Date.now = realNow;
  delete globalThis.caches;
});

test("returns the chyrons as TSV anyone can read", async () => {
  const res = await get("/third-eye?hours=1");
  assert.equal(res.status, 200);
  assert.equal(await res.text(), TSV);
  assert.equal(res.headers.get("access-control-allow-origin"), "*");
  assert.match(res.headers.get("content-type"), /text\/tab-separated-values/);
  assert.equal(res.headers.get("cache-control"), "public, max-age=30");
});

test("asks the archive for the right window, defaulting to 1 hour", async () => {
  await get("/third-eye");
  await get("/third-eye?hours=3");
  assert.deepEqual(calls.map((c) => c.url), [
    "https://archive.org/services/third-eye.php?last=1",
    "https://archive.org/services/third-eye.php?last=3",
  ]);
  assert.match(calls[0].init.headers["user-agent"], /curious\.strangeleaflet\.com/);
});

test("rejects hours outside 1 to 3", async () => {
  for (const hours of ["0", "4", "0.5", "lots", ""]) {
    const res = await get(`/third-eye?hours=${hours}`);
    assert.equal(res.status, 400, hours);
    assert.match(await res.text(), /hours must be/);
    assert.equal(res.headers.get("access-control-allow-origin"), "*");
  }
  assert.equal(calls.length, 0);
});

test("asks the archive once a minute however many people are watching", async () => {
  await get("/third-eye");
  await get("/third-eye");
  now += 59_000;
  await get("/third-eye");
  assert.equal(calls.length, 1);
  now += 2_000;
  await get("/third-eye");
  assert.equal(calls.length, 2);
});

test("a new isolate uses the data center's copy", async () => {
  await get("/third-eye");
  await newIsolate();
  await get("/third-eye");
  assert.equal(calls.length, 1);
});

test("works where the cache API isn't there", async () => {
  delete globalThis.caches;
  const res = await get("/third-eye");
  assert.equal(await res.text(), TSV);
  await get("/third-eye");
  assert.equal(calls.length, 1);
});

test("serves the last copy when the archive fails", async () => {
  await get("/third-eye");
  now += 5 * 60_000;
  answer = () => new Response("bad arg", { status: 503 });
  const res = await get("/third-eye");
  assert.equal(res.status, 200);
  assert.equal(await res.text(), TSV);
});

test("a new isolate falls back to the data center's stale copy", async () => {
  await get("/third-eye");
  await newIsolate();
  now += 5 * 60_000;
  answer = () => { throw new Error("timeout"); };
  const res = await get("/third-eye");
  assert.equal(res.status, 200);
  assert.equal(await res.text(), TSV);
});

test("a 200 that isn't chyrons counts as a failure", async () => {
  answer = () => new Response("<html>maintenance</html>");
  const res = await get("/third-eye");
  assert.equal(res.status, 502);
  assert.equal(res.headers.get("access-control-allow-origin"), "*");
});

test("says so when the archive fails and nothing is cached", async () => {
  answer = () => { throw new Error("timeout"); };
  const res = await get("/third-eye?hours=2");
  assert.equal(res.status, 502);
  assert.match(await res.text(), /Internet Archive/);
});

test("stale copies don't last forever", async () => {
  await get("/third-eye");
  now += 7 * 60 * 60_000;
  answer = () => new Response("", { status: 503 });
  assert.equal((await get("/third-eye")).status, 502);
});

test("other paths and methods are turned away", async () => {
  assert.equal((await get("/")).status, 404);
  assert.equal((await get("/third-eye", { method: "POST" })).status, 405);
});
