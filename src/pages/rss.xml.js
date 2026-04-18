import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const entries = await getCollection('docs', (entry) => entry.id.startsWith('articles/'));

  const items = entries
    .filter((entry) => entry.data.draft !== true)
    .map((entry) => ({
      title: entry.data.title,
      pubDate: entry.data.publishDate,
      description: entry.data.description,
      link: `/${entry.id}/`,
    }))
    .sort((a, b) => {
      const aTime = a.pubDate ? new Date(a.pubDate).getTime() : 0;
      const bTime = b.pubDate ? new Date(b.pubDate).getTime() : 0;
      return bTime - aTime;
    });

  return rss({
    title: 'Factory Engineering',
    description: 'Build Your Software Factory — articles on composable AI skills, commands, agents, and workflows.',
    site: context.site,
    items,
  });
}
