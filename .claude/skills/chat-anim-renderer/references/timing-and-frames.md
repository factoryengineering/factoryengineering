# Timing, frames, and the animationComplete contract

## The contract between template.html and capture.js

`template.html` is responsible for:

1. Running the typewriter animation on `DOMContentLoaded`.
2. Waiting for `document.fonts.ready` before typing so glyphs don't reflow mid-frame.
3. Dispatching `window.dispatchEvent(new Event('animationComplete'))` exactly once,
   after the final character of the final message is rendered.
4. **Not** looping or resetting. Looping is a GIF-encoder property.

`capture.js` is responsible for:

1. Screenshotting at `1000 / config.fps` intervals starting at page load.
2. Listening for `animationComplete` via `page.exposeFunction` + bridge event.
3. After the event fires, capturing an additional
   `round(pause_on_last_ms / 1000 × fps)` frames of the final state.
4. Writing `frame_%04d.png` into the scratch directory.

Violating this contract is the #1 source of bugs. If frames are missing, check
whether the template dispatched the event. If the GIF is truncated mid-message,
check that `animationComplete` fires only after *all* exchanges complete.

## Timing math

For an exchange with text of length `N`:

```
think_pause  = think_delay_ms
type_time    = char_delay_ms × N        // char_delay depends on role
exchange_ms  = think_pause + type_time
```

Total animation duration:

```
total_ms = sum(exchange_ms for each exchange) + pause_on_last_ms + ~100ms startup
```

At `fps = 15`, a 10-second animation is 150 frames + trailing pause frames.
A 30-second GIF is rarely what you want — warn authors and shorten text.

## Frame-rate determinism

The capture loop is driven by `setTimeout`, not `requestAnimationFrame`. This
means wall-clock frame spacing, not display-sync. Frame timing drifts slightly
from the animation's own `setTimeout` chain, which is fine because both run in
the same headless browser clock.

Do **not** use `page.waitForTimeout` inside the capture loop — it yields control
to Puppeteer's internal scheduler and inflates per-frame latency.

## Why we bake the pause into frames

GIF89a has a loop-delay extension, but viewer support is inconsistent. Repeating
the last N identical frames is bit-for-bit portable and adds negligible filesize
after palette compression (identical frames compress to near-zero).

## Font loading

`document.fonts.ready` is the load gate. If a custom font like
`JetBrainsMono-Regular.ttf` is not installed on the CI runner, the browser falls
back silently and glyph widths shift. Either:

- Install the font on the runner (`fonts-jetbrains-mono` on apt-based systems), or
- Embed it via `@font-face` with a base64 data URL inside `template.html`.

The provided `template.html` uses the system monospace stack with `ui-monospace`
fallback, so it renders consistently without custom fonts.
