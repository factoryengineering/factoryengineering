---
title: "Simple Documentation Factory"
description: "A minimal factory setup for generating and maintaining project documentation"
difficulty: "beginner"
tags: ["documentation", "markdown", "beginner"]
githubUrl: "https://github.com/factoryengineering/example-docs-factory"
---

# Simple Documentation Factory

This example demonstrates a basic factory configuration for documentation workflows.

## Components Used

- **doc-coauthoring skill**: Structured workflow for writing documentation
- **pdf skill**: Convert documentation to PDF format
- **markdown linting agent**: Ensure consistent markdown style

## Setup

1. Install the required skills
2. Configure your documentation structure
3. Run the workflow

## Example Configuration

```yaml
factory:
  name: "docs-factory"
  components:
    - skill: doc-coauthoring
    - skill: pdf
    - agent: markdown-linter
```

## Use Cases

- Project README files
- API documentation
- Technical specifications
- User guides
