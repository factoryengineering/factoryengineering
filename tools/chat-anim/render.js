#!/usr/bin/env node
// CLI entry point for chat-anim pipeline.
// Usage:
//   node render.js --file content/foo/bar.chat.yaml
//   node render.js --glob 'content/**/*.chat.yaml'

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');
const yaml = require('js-yaml');
const Handlebars = require('handlebars');
const { globSync } = require('glob');

const defaults = require('./defaults');
const { capture } = require('./capture');

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--file') args.file = argv[++i];
    else if (a === '--glob') args.glob = argv[++i];
    else if (a === '--keep-frames') args.keepFrames = true;
  }
  return args;
}

function loadConversation(yamlPath) {
  const raw = fs.readFileSync(yamlPath, 'utf8');
  const doc = yaml.load(raw);
  if (!doc || !Array.isArray(doc.exchanges) || doc.exchanges.length === 0) {
    throw new Error(`${yamlPath}: missing or empty 'exchanges' list`);
  }
  for (const ex of doc.exchanges) {
    if (ex.role !== 'user' && ex.role !== 'assistant') {
      throw new Error(`${yamlPath}: exchange role must be 'user' or 'assistant', got '${ex.role}'`);
    }
    if (typeof ex.text !== 'string' || ex.text.length === 0) {
      throw new Error(`${yamlPath}: exchange text must be a non-empty string`);
    }
  }
  const config = Object.assign({}, defaults, doc.config || {});
  return { config, exchanges: doc.exchanges };
}

function renderHtml(templatePath, config, exchanges) {
  const tpl = Handlebars.compile(fs.readFileSync(templatePath, 'utf8'));
  return tpl({
    config,
    config_json: JSON.stringify(config),
    exchanges_json: JSON.stringify(exchanges),
  });
}

function encodeGif(framesDir, fps, outGif, encoder) {
  const framePat = path.join(framesDir, 'frame_%04d.png');
  if (encoder === 'gifski') {
    const frameGlob = path.join(framesDir, 'frame_*.png');
    const frames = globSync(frameGlob).sort();
    execFileSync(
      'gifski', ['--fps', String(fps), '--quality', '90', '-o', outGif, ...frames],
      { stdio: 'inherit' }
    );
  } else {
    const palette = path.join(framesDir, 'palette.png');
    execFileSync(
      'ffmpeg', ['-y', '-framerate', String(fps), '-i', framePat,
        '-vf', 'palettegen=stats_mode=full', palette],
      { stdio: 'inherit' }
    );
    execFileSync(
      'ffmpeg', ['-y', '-framerate', String(fps), '-i', framePat, '-i', palette,
        '-lavfi', 'paletteuse=dither=bayer:bayer_scale=5', '-loop', '0', outGif],
      { stdio: 'inherit' }
    );
  }
}

async function processOne(yamlPath, opts) {
  console.log(`[chat-anim] ${yamlPath}`);
  const { config, exchanges } = loadConversation(yamlPath);

  const templatePath = path.join(__dirname, 'template.html');
  const html = renderHtml(templatePath, config, exchanges);

  const stamp = Date.now();
  const scratch = path.join(os.tmpdir(), `chat-anim-${stamp}`);
  fs.mkdirSync(scratch, { recursive: true });
  const htmlPath = path.join(scratch, 'index.html');
  fs.writeFileSync(htmlPath, html);

  const framesDir = path.join(scratch, 'frames');
  const { frameCount } = await capture(htmlPath, config, framesDir);
  console.log(`[chat-anim]   captured ${frameCount} frames`);

  const outDir = path.join('public', 'animations');
  fs.mkdirSync(outDir, { recursive: true });
  const baseName = path.basename(yamlPath).replace(/\.chat\.yaml$/, '.gif');
  const outGif = path.join(outDir, baseName);
  encodeGif(framesDir, config.fps, outGif, config.encoder || 'ffmpeg');
  console.log(`[chat-anim]   wrote ${outGif}`);

  if (!opts.keepFrames) {
    fs.rmSync(scratch, { recursive: true, force: true });
  } else {
    console.log(`[chat-anim]   frames kept in ${scratch}`);
  }
}

async function main() {
  const args = parseArgs(process.argv);
  let files = [];
  if (args.file) files = [args.file];
  else if (args.glob) files = globSync(args.glob);
  else {
    console.error('Usage: render.js --file <path> | --glob <pattern> [--keep-frames]');
    process.exit(2);
  }

  if (files.length === 0) {
    console.error('No .chat.yaml files matched.');
    process.exit(1);
  }

  for (const f of files) {
    await processOne(f, args);
  }
}

main().catch(err => { console.error(err); process.exit(1); });
