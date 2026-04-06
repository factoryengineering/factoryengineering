# YAML conversation schema (`.chat.yaml`)

Source of truth for the conversation input format.

## Structure

```yaml
config:        # optional — any key overrides defaults.js
  width: 720
  height: 420
  fps: 15
  char_delay_user_ms: 28
  char_delay_ai_ms: 18
  think_delay_ms: 900
  pause_on_last_ms: 2000
  encoder: ffmpeg    # or 'gifski'

exchanges:     # required, non-empty
  - role: user | assistant
    text: "string; newlines preserved via YAML block scalars"
```

## Field rules

| Field | Required | Constraint |
|---|---|---|
| `exchanges` | yes | Non-empty list |
| `exchanges[].role` | yes | Must be `user` or `assistant` |
| `exchanges[].text` | yes | Non-empty string |
| `config.*` | no | Any key valid; merges over `defaults.js` |

`render.js` validates these and aborts the whole build on violation — animations ship or nothing does.

## Authoring tips

- Use `|` block scalar for multi-line assistant messages (preserves newlines literally).
- Use `>` folded scalar when you want soft-wrapped prose collapsed to single lines.
- Keep messages short. Typewriter time scales linearly with character count:
  `duration_ms ≈ think_delay_ms + char_delay_ms × len(text)`
- Target total animation ≤ 15s for embedded reading pace. Estimate before capture
  to avoid surprise 30s GIFs.

## Alternating roles

The spec does not require strict alternation, but conversations read best when
`user` and `assistant` alternate. A double-`user` turn renders as two right-aligned
bubbles with no response between them.
