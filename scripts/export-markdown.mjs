import { copyFile, mkdir, readdir } from "node:fs/promises";
import path from "node:path";

const sourceDir = path.resolve("src/content/docs");
const targetDir = path.resolve("dist");
const markdownExtensions = new Set([".md", ".mdx"]);

async function exportDirectory(currentDir) {
  const entries = await readdir(currentDir, { withFileTypes: true });

  for (const entry of entries) {
    const sourcePath = path.join(currentDir, entry.name);
    if (entry.isDirectory()) {
      await exportDirectory(sourcePath);
      continue;
    }

    const ext = path.extname(entry.name).toLowerCase();
    if (!markdownExtensions.has(ext)) continue;

    const relativePath = path.relative(sourceDir, sourcePath);
    const targetRelativePath = relativePath.replace(/\.(md|mdx)$/i, ".md");
    const targetPath = path.join(targetDir, targetRelativePath);

    await mkdir(path.dirname(targetPath), { recursive: true });
    await copyFile(sourcePath, targetPath);
  }
}

await exportDirectory(sourceDir);
