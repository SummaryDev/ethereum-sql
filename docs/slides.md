# Convert markdown documents to slides

Install [marp](https://marpit.marp.app/).

```bash
npm install -g @marp-team/marp-cli
```

Convert to html (pdf with `--pdf`, pptx with `--pptx`).

```bash
marp docs/*.md --allow-local-files
```

Generate output continuously while editing markdown.

```bash
marp docs/how-we-index-store-and-decode.md --allow-local-files --pdf --watch
```
