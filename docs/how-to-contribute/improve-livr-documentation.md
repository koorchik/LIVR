# Improve this documentation

The site is built with [VitePress](https://vitepress.dev) from the [`docs/`](https://github.com/koorchik/LIVR/tree/master/docs) directory of the LIVR repository. For a small fix, use the "Edit this page on GitHub" link at the bottom of any page.

To run the site locally:

1. Fork and clone [koorchik/LIVR](https://github.com/koorchik/LIVR).
2. Install dependencies (Node.js 20 or newer): `npm install`
3. Start the dev server: `npm run docs:dev`
4. Open `http://localhost:5173/` and edit the files in `docs/`. The page reloads on save.
5. Check the production build: `npm run docs:build`
6. Open a pull request.

The site is deployed automatically from the `master` branch.

## Useful details

- The sidebar and the navigation are configured in `docs/.vitepress/config.mts`.
- A fenced code block with the `livr` language becomes an editable live example:

  ````md
  ```livr
  // rules
  { name: 'required' }
  // input
  { name: '' }
  ```
  ````

  An optional `// aliases` section takes a list of aliases.
- `<TestCases rule="required" />` shows the test suite cases of a rule.
- The list of implementations is generated from `docs/data/implementations.json`. After changing it, run `npm run readme` to update the repository README.
- Set `LIVR_DOCS_OFFLINE=1` to build the site without fetching package versions and repository activity.
