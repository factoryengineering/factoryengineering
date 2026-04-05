// Visual and timing defaults for chat-anim pipeline.
// Aligned to factoryengineering.dev dark theme.
// Any new parameter must be defined here before being referenced elsewhere.

module.exports = {
  // Canvas
  width:              720,
  height:             420,
  fps:                15,

  // Timing (milliseconds)
  char_delay_user_ms: 28,
  char_delay_ai_ms:   18,
  think_delay_ms:     900,
  pause_on_last_ms:   2000,

  // Theme
  theme:              'dark',

  // Colors (dark theme)
  bg:                 '#0d0f14',
  surface:            '#161a23',
  border:             '#252a38',
  user_bg:            '#1a2540',
  user_text:          '#b8caf5',
  user_label:         '#4f8aff',
  ai_bg:              '#141c14',
  ai_text:            '#a8d5b8',
  ai_label:           '#3eca7a',
  muted:              '#5a6080',

  // Typography
  font_mono:          'JetBrainsMono-Regular.ttf',
  font_display:       'Syne-ExtraBold.ttf',
  font_size_bubble:   13,
  line_height:        1.65,

  // Layout
  bubble_max_width_pct: 0.82,
  bubble_padding:       '14px 18px',
  bubble_gap:           20,
  window_padding:       24,

  // Encoder: 'ffmpeg' (default) or 'gifski'
  encoder:            'ffmpeg',
};
