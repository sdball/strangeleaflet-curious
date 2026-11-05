# strangeleaflet-cabient

A cabinet of curiousities I can serve up from curious.strangeleaflet.com.

## Run it locally

```sh
scripts/serve        # http://localhost:8020/
scripts/serve 9000   # or pick a port
scripts/serve --list # Python servers still running, with their pids
```

With [direnv](https://direnv.net/), run `direnv allow` once and `.envrc` puts
`scripts/` on your PATH here, so `serve` works without the prefix.

## Analytics

Every page in `public/` includes the GoatCounter snippet just before `</head>`. A pre-commit hook refuses commits that add or change a page without it, and the deploy workflow checks again before publishing.

After cloning, turn on the hook once:

```sh
git config core.hooksPath .githooks
```
