# Embedding in Astro Starlight

The pipeline spec shows an Eleventy shortcode, but this repo is Astro Starlight.
Use a presentational `.astro` component instead.

## Component

Create `src/components/user-components/ChatAnim.astro`:

```astro
---
interface Props {
  src: string;         // resolved path to the .gif, relative to site root
  alt?: string;
}
const { src, alt = 'Chat animation' } = Astro.props;
---
<div class="chat-anim-embed">
  <img src={src} alt={alt} class="chat-anim-img" loading="lazy" />
</div>

<style>
  .chat-anim-embed {
    clear: both;
    display: flow-root;
    margin-bottom: 2rem;
  }
  .chat-anim-img {
    display: block;
    max-width: 360px;
    width: 100%;
    height: auto;
    border-radius: 10px;
    border: 1px solid #252a38;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.4);
  }
  @media (min-width: 900px) {
    .chat-anim-img { float: right; margin: 0 0 1.5rem 2rem; }
  }
  @media (max-width: 899px) {
    .chat-anim-img { float: none; max-width: 100%; margin: 0 0 1.5rem 0; }
  }
</style>
```

## Usage in MDX

```mdx
import ChatAnim from '~/components/user-components/ChatAnim.astro';

<ChatAnim src="/animations/ask-plan-agent.gif" alt="Ask-Plan-Agent cycle demo" />

The Ask-Plan-Agent cycle front-loads human judgment to the cheapest moment...
```

## Asset placement

Astro serves `public/` at site root. Put build-output GIFs in
`public/animations/` (or adjust the render.js output path to match). Do **not**
place GIFs next to the MDX in `src/content/docs/` unless you configure Astro
image pipelines — raw GIFs in content collections are not served automatically.

## Section isolation

`clear: both` on `.chat-anim-embed` prevents two consecutive embeds from
floating side-by-side. `display: flow-root` contains the float so wrapping
prose stays bounded to its own section.
