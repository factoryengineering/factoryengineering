// Puppeteer frame-capture for chat-anim pipeline.
// Exports: capture(htmlPath, config, outDir) -> Promise<{frameCount}>

const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

async function capture(htmlPath, config, outDir) {
  fs.mkdirSync(outDir, { recursive: true });

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: config.width, height: config.height },
  });

  const page = await browser.newPage();
  await page.setViewport({
    width: config.width,
    height: config.height,
    deviceScaleFactor: 1,
  });

  // Expose completion flag BEFORE navigation so animationComplete cannot race.
  await page.exposeFunction('__markComplete', () => { completed = true; });
  let completed = false;

  await page.evaluateOnNewDocument(() => {
    window.addEventListener('animationComplete', () => {
      // eslint-disable-next-line no-undef
      window.__markComplete();
    });
  });

  const fileUrl = 'file://' + path.resolve(htmlPath);
  await page.goto(fileUrl, { waitUntil: 'networkidle0' });

  const frameIntervalMs = 1000 / config.fps;
  const extraFrames = Math.round((config.pause_on_last_ms / 1000) * config.fps);

  let frameIndex = 0;
  const captureFrame = async () => {
    const filename = path.join(outDir, `frame_${String(frameIndex).padStart(4, '0')}.png`);
    await page.screenshot({ path: filename, type: 'png', omitBackground: false });
    frameIndex++;
  };

  // Main loop: capture until animationComplete fires.
  while (!completed) {
    const t0 = Date.now();
    await captureFrame();
    const elapsed = Date.now() - t0;
    const wait = Math.max(0, frameIntervalMs - elapsed);
    await new Promise(r => setTimeout(r, wait));
  }

  // Trailing pause: repeat final-frame captures to bake the hold into the GIF.
  for (let i = 0; i < extraFrames; i++) {
    const t0 = Date.now();
    await captureFrame();
    const elapsed = Date.now() - t0;
    const wait = Math.max(0, frameIntervalMs - elapsed);
    await new Promise(r => setTimeout(r, wait));
  }

  await browser.close();
  return { frameCount: frameIndex };
}

module.exports = { capture };
