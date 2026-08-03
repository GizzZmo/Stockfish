#!/usr/bin/env node
/**
 * generate-screenshots.mjs
 * Capture full-page screenshots of a running web app with Playwright.
 *
 * Usage (from a package dir that has playwright installed, e.g. matrix-gui/):
 *   node ../scripts/generate-screenshots.mjs --url http://127.0.0.1:4173 --out ../screenshots/app --name app --widths 1280,1920,390
 *
 * Playwright is resolved from process.cwd() (the package directory), not from
 * scripts/, because ESM import resolution ignores NODE_PATH.
 */

import { createRequire } from 'node:module';
import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { parseArgs } from 'node:util';

// Resolve 'playwright' from the caller's working directory (e.g. matrix-gui/node_modules),
// not from scripts/ — static `import from 'playwright'` only walks up from this file.
const requireFromCwd = createRequire(join(process.cwd(), 'package.json'));
let chromium;
try {
  ({ chromium } = requireFromCwd('playwright'));
} catch (err) {
  console.error(
    "Cannot find package 'playwright' from cwd=%s\n" +
      'Install it in the package you run from, e.g.:\n' +
      '  npm install -D playwright\n' +
      '  npx playwright install chromium\n' +
      'Original error: %s',
    process.cwd(),
    err.message,
  );
  process.exit(1);
}

const { values } = parseArgs({
  options: {
    url: { type: 'string', default: 'http://127.0.0.1:4173' },
    out: { type: 'string', default: 'screenshots' },
    name: { type: 'string', default: 'app' },
    widths: { type: 'string', default: '1280,1920,390' },
    wait: { type: 'string', default: '2000' },
  },
});

const url = values.url;
const outDir = values.out;
const name = values.name;
const widths = values.widths.split(',').map((w) => parseInt(w.trim(), 10)).filter(Boolean);
const waitMs = parseInt(values.wait, 10) || 2000;

if (!widths.length) {
  console.error('No valid widths provided (got: %s)', values.widths);
  process.exit(1);
}

async function main() {
  await mkdir(outDir, { recursive: true });

  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const results = [];

  for (const width of widths) {
    const height = width <= 500 ? 844 : 800;
    const context = await browser.newContext({
      viewport: { width, height },
      deviceScaleFactor: 1,
    });
    const page = await context.newPage();

    try {
      console.log(`Navigating to ${url} @ ${width}x${height}...`);
      await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });
      await page.waitForTimeout(waitMs);

      const file = join(outDir, `${name}-${width}px.png`);
      await page.screenshot({
        path: file,
        fullPage: true,
        type: 'png',
      });
      console.log(`Saved ${file}`);
      results.push({ width, height, file });
    } catch (err) {
      console.error(`Failed at width ${width}:`, err.message);
      try {
        const file = join(outDir, `${name}-${width}px-error.png`);
        await page.screenshot({ path: file, fullPage: false, type: 'png' });
        results.push({ width, height, file, error: err.message });
      } catch (_) {
        /* ignore secondary capture failure */
      }
    } finally {
      await context.close();
    }
  }

  await browser.close();

  if (!results.length) {
    console.error('No screenshots were captured');
    process.exit(1);
  }

  const meta = {
    url,
    name,
    generatedAt: new Date().toISOString(),
    screenshots: results,
  };
  await writeFile(join(outDir, `${name}-meta.json`), JSON.stringify(meta, null, 2));
  console.log('Done.', results.length, 'screenshot(s)');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
