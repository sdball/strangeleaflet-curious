# The Cabinet of Curios

Static site served at curious.strangeleaflet.com: interactive exhibits, toys, guides, and gadgets from Strange Leaflet. There is no build step for the site, no package manager, no framework, and no test suite. Every page is one self-contained `index.html`, hand-written except for any prose regions `scripts/render` fills in from Markdown (see **Prose in Markdown**).

## Layout

```
public/index.html          the hub: the shelf of curio tags plus a text-adventure interface
public/<slug>/index.html   one curio per directory, served at /<slug>/
public/<slug>/*.md         prose that scripts/render copies into the page, if the page has any
scripts/serve              serves public/ locally (python3 http.server)
scripts/render             fills pages' marked regions from Markdown (Node, no dependencies)
.githooks/pre-commit       refuses staged pages without the GoatCounter snippet, out of date with their Markdown, or with tic-check findings
.github/workflows/static.yml  checks GoatCounter again, then deploys public/ to GitHub Pages
api/                       a Cloudflare Worker that proxies outside data for curios (not published with the site)
stories/                   builds the Z-machine curios' story files from their ZIL source (not published)
```

Pushing to `main` deploys. Only `public/` is published.

## Run it locally

```sh
scripts/serve          # then open http://localhost:8020/
scripts/serve 9000     # or pick a port
scripts/serve --list   # Python servers still running, with their pids
```

Use a server, not `file://`. Each page's back link points at `/`, which only works when served.

After cloning, turn on the hook once: `git config core.hooksPath .githooks`. `direnv allow` once puts `scripts/` on PATH via `.envrc`.

## Prose in Markdown

A page can keep its wordier regions (Things to notice, A little history, Sources, guide lessons) in Markdown files next to it. A pair of comments marks each region, and `scripts/render` replaces what's between them with the rendered file:

```html
<section class="notes" aria-labelledby="notice-h">
  <h2 id="notice-h">Things to notice</h2>
  <!-- md: notes.md -->
  …generated, so edit notes.md instead…
  <!-- /md -->
</section>
```

```sh
scripts/render           # render every page with markers
scripts/render --watch   # keep rendering as you edit; reload the browser to see it
scripts/render --check   # list pages out of date with their Markdown
```

The generated HTML is committed with its Markdown, like the story files, so the site still deploys `public/` as it is and every page stays self-contained. The pre-commit hook runs `scripts/render --staged` and refuses a page whose staged HTML doesn't match its staged Markdown. `not-a-number` is the first page converted.

- **Keep the frame in HTML.** The `<section>`, its `aria-labelledby`, and its `h2` stay in the page. The Markdown holds only what goes inside.
- **The Markdown is a small subset**: paragraphs, `-` and `1.` lists (nest by indenting), `#` headings, ``` fences, `` `code` ``, `[links](url)`, and a trailing `\` for a line break. `**bold**` renders as `<b>` and `*italic*` as `<i>`, the tags the exhibits' notes already use and style. An item with one paragraph renders as a bare `<li>…</li>`.
- **Raw HTML still works.** Inline tags pass through (`<span class="v">`, `<kbd>`, `<strong>`), and a line opening with a block tag (`<p class="note">`, `<div>`, `<table>`) starts a raw block that runs to the next blank line, with no Markdown inside it.
- **One item or paragraph per line.** That's how the pages write them, and it keeps diffs to the sentence you changed.
- **The writing rules still apply.** `tic-check` reads the rendered page, so a tic in the Markdown shows up there. For a deliberate use, end the Markdown line with `<!-- tic-ok -->`. It passes through as a comment onto the same rendered line.

## The API Worker

`api/` is one plain JS file run by Cloudflare Workers, with tests that need nothing but Node. It deploys by hand, separately from the site.

```sh
node --test api/worker.test.mjs     # tests, with the outside sources stubbed
cd api && npx wrangler dev          # serves it at http://localhost:8787/
cd api && npx wrangler deploy       # publishes it to https://curious-api.sdball.workers.dev
```

## The story files

The Z-machine curios (`z-machine`, `z-machine-interpreter`) carry two games built with ZILF: *After Hours at the Cabinet*, written for the cabinet, and Zork I from Infocom's released source. The ZIL source lives in `public/z-machine/` so visitors can read it; `stories/<game>/` links to it and holds the build. Building needs ZILF (`zilf`, `zapf`) and Frotz's `dfrotz` on PATH.

```sh
stories/after-hours/check   # build, replay every walkthrough (each must win), copy into both curios
stories/zork1/check         # build, walk to the cellar, copy into both curios
```

`check` copies the `.z3` into each curio that carries one and writes the names JSON with `names`. The analyzer reads it, and so does the interpreter: its Enhanced line for the Zorks finds the clock table, the lamp's timer, the load limit, and the lamp object by name, and its Inspector panel names objects, attributes, properties, globals, and routines for all four built-in stories. Commit the copies in `public/` with the source change that made them. After changing After Hours, add a walkthrough step for anything new.

The interpreter is checked against `dfrotz` with the same walkthroughs. `stories/play.mjs` runs the page's own engine in Node (the script between its `Story file` and `Page` sections), and `stories/compare` diffs its transcript against dfrotz's word by word.

```sh
stories/check-interpreter                        # every walkthrough, through both
stories/compare game.z5 commands.txt             # any story file and commands of your own
node stories/play.mjs game.z5 commands.txt       # just the page's transcript
```

Run `check-interpreter` after changing the interpreter's engine; each line should say `same`.

Saves are Quetzal files, the format dfrotz and most interpreters share, so the interpreter's are checked against dfrotz's too. `check-saves` plays each walkthrough half way, saves with both, then restores each save with both and plays on; all four endings must match. With `--files`, `play.mjs` reads a file name after `save` and `restore`, as dfrotz does.

```sh
stories/check-saves                       # every walkthrough
stories/check-saves game.z5 commands.txt  # any story file and commands of your own
```

## Rules for every page

- **GoatCounter goes just before `</head>`**, exactly this. The hook and the deploy both grep for the `data-goatcounter` URL, and the deploy fails without it.

  ```html
  <script>
    window.goatcounter = {
      path: function(p) { return location.host + p }
    }
  </script>
  <script data-goatcounter="https://sdball.goatcounter.com/count"
          async src="//gc.zgo.at/count.js"></script>
  ```

- **Self-contained.** CSS in one `<style>` in the head, JS in one `<script>` at the end of the body. No shared stylesheets or scripts between pages, no JS libraries, no CDNs. Every page may load Google Fonts and GoatCounter. A curio built around outside data (a live feed, an RSS reader) may also fetch that data, but only data, never code, and it should say on the page where the data comes from and still render something useful when the source is down. Data meant to be edited by hand can live in a JSON file in the curio's own directory and be fetched the same way (`claude-verbs` reads `playlists.json`). An image can sit in the curio's own directory too, compressed to WebP at about twice its displayed width, with `width`, `height`, and alt text on the `<img>` (`not-a-number` shows `is-this-a-number.webp`).
- **Outside data that needs a proxy.** Sources that send no CORS headers go through the Cloudflare Worker in `api/`, not a public CORS proxy. Add a route to `api/worker.js` that fetches through its `cached()` helper and answers with `access-control-allow-origin: *`, add tests to `api/worker.test.mjs`, and keep a `?proxy=` override in the page so it can be tried against `wrangler dev`. `chyron-wire` reads `/third-eye` that way.
- **Its own look.** Each curio has its own palette and fonts suited to its subject (garage-wall odometers, telegraph-office Morse, pixel-art Pocket Places). Share structure and conventions with the other pages, not styles. Don't extract common CSS.
- **Light and dark.** Define colors as custom properties on `:root`, then redefine them under both `@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { … } }` and `:root[data-theme="dark"] { … }`. Set `color-scheme` to match.
- **Works on a phone.** `viewport-fit=cover`, safe-area padding on `:root`, tap targets of 40–44px, text inputs at 16px or larger (stops iOS zooming on focus), no horizontal page scroll. Wrap wide tables in `.table-wrap { overflow-x: auto; }`.
- **Accessible.** Visible `:focus-visible` outlines, `aria-pressed` on toggle buttons, `aria-live="polite"` on captions that narrate changes, `role="img"` plus an `aria-label` on explanatory SVGs, and every drag interaction also reachable by keyboard (Tab to the handle, arrow keys to nudge, Shift for bigger steps).
- **Respects reduced motion.** Check `matchMedia("(prefers-reduced-motion: reduce)")` before animating, and turn transitions off in a `@media (prefers-reduced-motion: reduce)` block.

## Adding a new curio

1. Create `public/<slug>/index.html`. The slug is lowercase and hyphenated (`morse-code`, `exploring-e`).
2. Start the head from this skeleton (taken from the current exhibits):

   ```html
   <!doctype html>
   <html lang="en">
   <head>
   <meta charset="utf-8">
   <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
   <title>Name — The Cabinet of Curios</title>
   <meta name="description" content="One or two plain sentences about what you can do here.">
   <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🔢</text></svg>">
   <link rel="preconnect" href="https://fonts.googleapis.com">
   <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
   <link href="https://fonts.googleapis.com/css2?family=…&display=swap" rel="stylesheet">
   <style>…</style>
   <!-- GoatCounter snippet -->
   </head>
   ```

   The favicon is a single emoji. Pick one no other curio uses.
3. Open the body with the shared frame:

   ```html
   <div class="wrap">
     <a class="back" href="/">The Cabinet of Curios</a>
     <h1>Name</h1>
     <p class="lede">What this is and what you'll see, in two or three sentences.</p>
     …
   </div>
   ```

   `.wrap` is `max-width: 960px; margin: 0 auto;` with about 1.25rem side padding.

   Guides use the two-column frame described under **Guide structure** instead.
4. Register it in the `CURIOS` array in `public/index.html`, at the end unless asked otherwise:

   ```js
   { id: "odometers", name: "Odometers", kind: "exhibit", href: "odometers/",
     blurb: "Explore how number bases work: base-10, base-2, clock, and factorial base.",
     words: ["odometers", "odometer"] },
   ```

   - `kind` is `exhibit` (learn something by playing with it), `toy` (just for fun), `guide` (a walkthrough), or `gadget` (a working instrument, often fed by outside data, like `chyron-wire`). These drive the hub's filter buttons.
   - The tag's "No. N" comes from array position, so reordering renumbers every tag.
   - `href` is relative with a trailing slash.
   - `words` are the nouns the text interface answers to (`get morse`, `examine odometer`). `words[0]` appears in the "Try get …" hint, so make it the most obvious one. A curio matches if any typed word is in its `words`, so avoid generic words another curio might also claim.
   - The blurb sits on a small paper tag. Keep it to about one sentence that says what you do there.
5. Cross-link related curios with relative links (`<a href="../lehmer-codes/">`) where one explains the other.

Keep `DEMO` and `SIMULATE_DIRECT_ARRIVAL` in the hub set to `false`. They're for previewing the text interface.

## Exhibit structure

The newer exhibits (`complex-numbers`, `exploring-e`, `morse-code`, `odometers`, `lehmer-codes`) share a shape worth following:

- `.back`, `h1`, `.lede`, and optionally a `.howto` line explaining the controls.
- One or more `<section class="panel">` blocks holding the interactive parts. Multi-step exhibits number them as stations: `<p class="station">Station 3</p>` above the `h2` in a `.panel-head`, each building on the last. Notes inside a station point forward to the next ("Station 2 makes room for it").
- `<section class="notes">` with **Things to notice**: a `<ul>` whose items open with a bold claim, then explain it.
- Optionally **A little history**, same format.
- `<section class="sources">` listing every source the history leans on, in citation form, linked where a stable URL exists. Don't add a historical claim without a source for it.
- Every section uses `aria-labelledby` pointing at its `h2` id.

## Guide structure

Guides are long, hands-on walkthroughs you work through over several sittings. `behringer-wave` is the model for them, and it swaps the exhibit frame for a two-column one:

- `.wrap` is a flex row up to 1360px wide: a sticky `<nav class="rail">` on the left and `<main class="main">` beside it. Below 960px the rail stacks above the content.
- The rail holds the `.back` link, a light/dark switch (`aria-pressed`, choice saved in `localStorage`), the guide's name, a **Continue** card pointing at the first unfinished lesson, and a link per section grouped under `.rail-part` headings. The current section's link is highlighted as you scroll.
- A `<header class="hero">` with an `.eyebrow` line, the `h1`, and a `.standfirst` saying what the guide covers and how to use it.
- Each lesson is a `<section>` with a `.sec-head` (a `.sec-num`, the `h2`, and optionally a button), then a `.goal` line saying what you'll get out of it. Orientation and reference sections use `·` in place of a number.
- Lessons give exact values to enter and say what you should hear or see. Callouts are `.note` blocks with a `.lbl`: `listen` (you should hear), `verify` (check it on your own unit), `warn` (a trap), `restore` (what to put back before the next lesson).
- Each lesson ends with a `.done` checkbox. Progress is saved in `localStorage`, wrapped in `try/catch`.
- Reference material (abbreviations, full tables, troubleshooting) sits at the end, then a `.foot` naming the sources the guide is built from.
- Every section uses `aria-labelledby` pointing at its `h2` id, as in exhibits.

`pocket-places` is a full-screen toy, not a document page, and is the model for that kind of curio: a fixed canvas filling the viewport, the title overlaid in a corner, controls in a floating tray that can be hidden, and its own day/night/storm palettes instead of light and dark tokens. It has no `.wrap` and no back link.

## JavaScript conventions

- Plain browser JS, no modules or build. `const $ = (id) => document.getElementById(id);` at the top.
- Sections divided by `// ---------- Name ----------` comments. Short lowercase comments explain why, not what.
- State lives in top-level `let`s or a small object per station, and a `paint()`/`draw()` function re-renders from state.
- Build SVG with a small `createElementNS` helper (`svgEl(tag, attrs, text)`); see `complex-numbers` and `exploring-e`.
- Global keyboard shortcuts ignore modified keys and typing in fields:

  ```js
  document.addEventListener("keydown", (e) => {
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    if (e.target.matches("input:not([type=range]), textarea, select")) return;
    …
  });
  ```

  Advertise shortcuts with `aria-keyshortcuts` and `<kbd>` in the captions.
- State worth sharing goes in the URL hash via `URLSearchParams` and `history.replaceState` (see `bitfield-explorer`, `minifloat-ruler`), with a footer line saying the link is shareable. Per-visitor preferences may use `localStorage`, always wrapped in `try/catch`.
- Audio uses the Web Audio API. On iOS, set `navigator.audioSession.type = "playback"`, resume when the state isn't `"running"`, and resume on `pointerup`/`touchend`/`keydown` since a touch `pointerdown` doesn't count as a gesture. See `morse-code`. Games use `"playback"` too (`hardpoint` tried `"ambient"`, and on a phone with the silent switch on it seemed broken), so give them their own Sound toggle.

## Sound effects

Game sounds are synthesized with Web Audio, never recorded files. A curio with sound effects keeps them as data: an object of sounds, each `{ "name", "use", "layers": [...] }`, where every layer is a tone or filtered noise:

```js
{ "kind": "tone", "wave": "sine", "freq": 80, "to": 30, "gain": 0.9, "attack": 0.003, "dur": 0.5 }
{ "kind": "noise", "filter": "lowpass", "freq": 1200, "to": 120, "q": 1, "gain": 1.1, "attack": 0.005, "dur": 0.9 }
```

`to` glides the pitch or cutoff, `at` starts the layer late, `vary` nudges its pitch at random on each play, and `repeat` scatters that many copies across `spread` seconds. Keep one layer per line and one sound per stanza (see `SOUNDS` in `hardpoint`). Play them with the same player and output chain as `hardpoint` (master gain 0.8 into a light limiter), so they sound the same everywhere.

`sound-bench` holds an identical copy of every curio's sounds as its presets, one set per curio (`HARDPOINT_SOUNDS`, registered in its `GROUPS`). The data is duplicated on purpose, so each page stays self-contained. When one copy changes, change the other to match in the same commit. A Sound Bench export (`{ "format": "sound-bench/1", "group": "hardpoint", "sounds": {...} }`) uses the same layout, so its `sounds` object pastes straight into both pages. A new curio with sounds adds its set to `sound-bench` too.

## Sprites

Pixel-art sprites are data too: an object of sprites, each `{ "name", "use", "palette", "frames" }`. The palette maps single letters to colors (`"#RRGGBB"`, `"*#RRGGBB"` glows in the dark, `"~#RRGGBB"` is see-through), and each frame is an array of row strings, one letter per pixel and a space for nothing. Art faces right. Keep one row per line and one sprite per stanza (see `SPRITES` in `cozy-submarine`).

Two optional fields: `"poses": { "perch": [0], "fly": [2, 3] }` names frames so a game can ask for one pose rather than cycling through every frame, and `"like": "bird"` makes a sprite borrow another's frames and poses while bringing its own palette (no `frames` of its own). `pocket-places` uses both: one bird drawing is its gull, crow, pigeon, and flock. Pad a sprite's frames to one size, placed so each pixel lands where the game draws it.

`pixel-bench` holds an identical copy of every curio's sprites, one set per curio (`COZY_SUBMARINE_SPRITES`, `POCKET_PLACES_SPRITES`, registered in its `GROUPS`), the same way `sound-bench` holds sounds. When one copy changes, change the other to match in the same commit. A Pixel Bench export (`{ "format": "pixel-bench/1", "group": "cozy-submarine", "sprites": {...} }`) writes `sprites` in the same layout, so it pastes straight into both pages. A new curio with sprites adds its set to `pixel-bench` too, with a `scene` for the bench's preview.

Cozy Submarine's own sub is not in that set. Players draw their own in `custom-submarine`, which saves it to `localStorage` for the game to sail.

## Writing style

- Plain, concrete, second person. Short sentences that say what to do and what you'll see ("Drag z and watch…", "Press +1 to count").
- No em dashes in body prose; use a period, colon, or comma. (Em dashes are fine in `<title>`.)
- Explain from what the visitor already knows, one idea at a time. Prefer turns, hops, and wheels to jargon, and define a term the first time it appears.
- In math, use the real minus sign `−` and `×`, and wrap variables in `<span class="v">` where the page styles them.
- `tic-check` (in `~/local_bin`, outside the repo) enforces the above plus a list of LLM tics (em dashes, "it's not X, it's Y", "let's dive in", "genuinely", "delve", and so on) on visible text and script strings. Rewrite the sentence rather than dodging the pattern. For a deliberate use, put `tic-ok` on that source line. The pre-commit hook runs it when it's on PATH and says so when it isn't.
- The hub's text interface is a Zork-style parser with in-jokes (leaflet, frotz, xyzzy). Keep new responses in that voice.
- The text interface opens as a full-screen Infocom-on-an-Atari-800 screen: VT323 with ligatures off, white on Atari blue, an inverse status line, nothing but the prompt. Like `pocket-places`, it keeps its own fixed palette instead of light and dark tokens. `quit` (confirmed with Y) or Esc closes it.

## Before you commit

- Serve locally and check the page in light and dark, at phone width (~375px), by keyboard alone, and with reduced motion on.
- Confirm the browser console is clean.
- If the page has Markdown regions, `scripts/render --check` should print nothing (the hook checks this too).
- `tic-check public/<slug>/index.html` should print nothing (the hook runs it too).
- `grep -L 'data-goatcounter="https://sdball.goatcounter.com/count"' public/*.html public/*/*.html` should print nothing.

Commit messages are imperative, sentence case, and name the curio: "Add a Morse code exhibit", "Let m reach the end of the line in complex numbers' station 1". For anything bigger than a small fix, add a body that explains what changed for the visitor and why. Keep one curio per commit where possible.
