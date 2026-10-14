// A small Cloudflare Worker that hands outside data to the curios.
// Sources here send no CORS headers, so pages can't read them directly.
//
//   GET /third-eye?hours=1|2|3   recent TV news chyrons from the Internet Archive's Third Eye

const THIRD_EYE = "https://archive.org/services/third-eye.php?last=";
const USER_AGENT = "curious.strangeleaflet.com chyron wire";
const FRESH = 60;           // seconds before asking the archive again
const STALE = 6 * 60 * 60;  // how long a copy stays around for when the archive stumbles
const BROWSER = 30;         // seconds a browser may keep its copy

// ---------- Routing ----------

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (request.method !== "GET" && request.method !== "HEAD") return text(405, "only GET");
    if (url.pathname === "/third-eye") return thirdEye(url, ctx);
    return text(404, "nothing here");
  },
};

// ---------- Third Eye ----------

// the archive only takes whole hours, counted back from the top of the hour
const HOURS = ["1", "2", "3"];

async function thirdEye(url, ctx) {
  const hours = url.searchParams.get("hours") ?? "1";
  if (!HOURS.includes(hours)) return text(400, "hours must be 1, 2 or 3");

  const body = await cached(`third-eye/${hours}`, url, ctx, async () => {
    const res = await fetch(THIRD_EYE + hours, {
      headers: { "user-agent": USER_AGENT },
      signal: AbortSignal.timeout(10_000),
    });
    const tsv = res.ok ? await res.text() : "";
    // a 200 can still be an error page, so check for the header row
    return tsv.startsWith("date_time") ? tsv : null;
  });

  if (body == null) return text(502, "the Internet Archive didn't answer");
  return new Response(body, {
    headers: {
      ...CORS,
      "content-type": "text/tab-separated-values; charset=utf-8",
      "cache-control": `public, max-age=${BROWSER}`,
    },
  });
}

// ---------- Cache ----------

// two layers: this isolate's memory, which always works, then Cloudflare's
// cache for this data center, which only does anything on a custom domain.
// either one keeps a stale copy to serve when the source fails.
const memory = new Map();

async function cached(name, url, ctx, load) {
  const now = Date.now();
  const kept = memory.get(name);
  if (kept && now - kept.at < FRESH * 1000) return kept.body;

  const edge = globalThis.caches?.default;
  const freshKey = new Request(new URL(`/__cache/${name}`, url));
  const staleKey = new Request(new URL(`/__cache/${name}/stale`, url));

  const hit = edge && await edge.match(freshKey);
  if (hit) {
    const body = await hit.text();
    memory.set(name, { body, at: now });
    return body;
  }

  let body = null;
  try { body = await load(); } catch { /* fall through to a stale copy */ }

  if (body != null) {
    memory.set(name, { body, at: now });
    if (edge) {
      ctx.waitUntil(edge.put(freshKey, keep(body, FRESH)));
      ctx.waitUntil(edge.put(staleKey, keep(body, STALE)));
    }
    return body;
  }

  if (kept && now - kept.at < STALE * 1000) return kept.body;
  const stale = edge && await edge.match(staleKey);
  return stale ? stale.text() : null;
}

const keep = (body, seconds) =>
  new Response(body, { headers: { "cache-control": `public, s-maxage=${seconds}` } });

// ---------- Responses ----------

// everything here is public, so any page may read it
const CORS = { "access-control-allow-origin": "*" };

const text = (status, message) =>
  new Response(message, { status, headers: { ...CORS, "content-type": "text/plain; charset=utf-8" } });
