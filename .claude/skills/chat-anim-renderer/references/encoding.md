# GIF encoding

The pipeline supports two encoders. FFmpeg is the default — it is available on
all CI runners. gifski produces higher quality at ~3-5x the encoding time.

## FFmpeg (default)

Two-pass palette-optimized encoding:

```bash
# Pass 1 — generate optimal palette from all frames
ffmpeg -y -framerate {fps} -i frame_%04d.png \
  -vf "palettegen=stats_mode=full" palette.png

# Pass 2 — encode with dithering + infinite loop
ffmpeg -y -framerate {fps} -i frame_%04d.png -i palette.png \
  -lavfi "paletteuse=dither=bayer:bayer_scale=5" \
  -loop 0 output.gif
```

### Dither options

| Value | When to use |
|---|---|
| `dither=none` | Flat-color UI; smallest file, visible banding on gradients |
| `dither=bayer:bayer_scale=5` | **Default.** Best balance for text + flat UI |
| `dither=sierra2_4a` | Photographic content or soft shadows |

### palettegen stats_mode

- `full` (default in this pipeline): samples every pixel of every frame. Best quality, higher encode time.
- `diff`: prioritizes changed pixels. Faster, but text anti-aliasing can wash out on static bubbles.

## gifski (opt-in)

```bash
gifski --fps {fps} --quality 90 -o output.gif frame_*.png
```

Gifski uses perceptual color quantization and tends to preserve anti-aliased text
noticeably better than ffmpeg. Tradeoff: no palette-reuse optimization, so
file sizes for long animations run larger.

Enable per-animation by adding `encoder: gifski` to the `config:` block in the
YAML file. Requires gifski to be installed (`cargo install gifski` or
`brew install gifski`).

## File size targets

For web embedding at the default 360×210 canvas:

| Duration | FFmpeg (default) | gifski q=90 |
|---|---|---|
| 5s | 200–400 KB | 400–800 KB |
| 10s | 400–800 KB | 800 KB – 1.5 MB |
| 15s | 700 KB – 1.2 MB | 1.2 – 2.2 MB |

If a GIF exceeds 2 MB, first shorten the conversation, then consider dropping
`fps` to 12, then switch to the default FFmpeg encoder if using gifski.
