import { cp, mkdir, rm } from "node:fs/promises";
import path from "node:path";

const sourceDir = path.resolve("src/content/docs");
const targetDir = path.resolve("public/markdown");

// Recreate the output directory on each build to prevent stale files.
await rm(targetDir, { recursive: true, force: true });
await mkdir(targetDir, { recursive: true });

await cp(sourceDir, targetDir, {
  recursive: true,
  filter: (filePath) => {
    const ext = path.extname(filePath).toLowerCase();
    if (!ext) return true;
    return ext === ".md" || ext === ".mdx";
  },
});
