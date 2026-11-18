---
title: "eval"
description: "The evidence-driven eval runner. It grows minimal skills, starting with `ef-linq`, by per-line ablation across models, and it is the running example for the Engineering a Software Factory series."
githubUrl: "https://github.com/factoryengineering/eval"
demonstrates:
  - "Minimal skills where every line is load bearing: `ef-linq`, `unit-testing`, `api-design`, and `idempotent-writes`"
  - "Per-line ablation: each rule is kept only if removing it significantly lowers the pass rate on at least one model"
  - "Executable graders that compile and run the generated C#, validated against known-good and known-bad reference solutions"
  - "An iteration log: one commit, one log entry, and one `PROGRESS.md` section per change"
---
