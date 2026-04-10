# Troubleshooting

## Puppeteer fails to launch on Linux CI

Symptom: `Failed to launch the browser process` or sandbox errors on GitHub Actions.

Fix: ensure `capture.js` launches with:

```js
puppeteer.launch({
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
});
```

This is already set in the bundled `capture.js`.

## GIF is truncated mid-typing

Symptom: output GIF ends before the final message finishes typing.

Cause: `animationComplete` fired too early, or the template has a bug that
prevents it from firing at all (in which case the capture loop never exits —
check for a hang instead).

Fix: confirm the template's `run()` function dispatches the event only after
the last character of the last exchange is rendered. The bundled template does
this correctly; custom templates must preserve this contract.

## Text looks fuzzy / anti-aliasing washes out

Symptom: bubble text appears soft or smeared in the final GIF, clear in raw PNGs.

Cause: ffmpeg palette quantization is collapsing similar anti-aliased pixels.

Fix: in order of escalation:

1. Raise font size (`font_size_bubble`) by 1–2px.
2. Switch to `encoder: gifski` in the YAML config.
3. Change the text color to have higher contrast against the bubble background.

## Frames captured faster/slower than `fps`

Symptom: animation plays too fast or too slow in the GIF.

Cause: the capture loop used `page.waitForTimeout` or the screenshot took longer
than one frame interval.

Fix: the bundled `capture.js` uses `Date.now()` deltas to maintain target fps
even when screenshots take variable time. If running a custom capture loop, measure
elapsed time per frame and subtract from the sleep interval.

## GIF loops, but the pause on the last frame is missing

Cause: the extra-frames calculation rounded to zero, or
`pause_on_last_ms` was not merged from defaults.

Fix: confirm `config.pause_on_last_ms` is > 0 in the merged config. At `fps=15`
and `pause_on_last_ms=4000`, expect 60 trailing identical frames.

## Output is placed in the wrong directory

The GIF is written by replacing the `.chat.yaml` suffix with `.gif` on the
original path. If the YAML lives at `content/foo/bar.chat.yaml`, the GIF lands
at `content/foo/bar.gif`. Move the YAML, not the GIF, to relocate output.

## Adding `.gif` files to git

Build outputs should be gitignored:

```
content/**/*.gif
```

Commit only the deployed site (e.g. `_site/` or `dist/`) if a host requires
checked-in artifacts.
