---
title: Exposing Markdown Files on Azure
description: Options for implementing agent-friendly access to Markdown files in Azure Static Web Apps.
---

# Exposing Markdown Files on Azure

This document explains the implementation options for exposing Markdown files hosted on Azure Static Web Apps. These methods prioritize compatibility with agent integration and automation workflows.

---

## 1. HTTP Content Negotiation
Azure Static Web Apps can be configured to serve Markdown files directly and enable content negotiation based on `Accept` headers.

### Steps:
1. Ensure Markdown files are located in a consistently structured directory (e.g., `src/content/docs`).
2. Update the `routes` property in `staticwebapp.config.json`:
   ```json
   {
     "routes": [
       {
         "route": "/docs/*",
         "serve": "src/content/docs/{path}.md",
         "headers": {
           "Content-Type": "text/markdown"
         }
       }
     ]
   }
   ```
3. Verify Markdown accessibility in Azure's staging or production environments.

---

## 2. API Endpoints for Markdown Access
Create Azure Functions to expose Markdown files programmatically, enhancing metadata exposure for agent consumption.

### Steps:
1. Add an Azure Function to the `api` directory:
   - Function: `getMarkdownContent`
   - Purpose: Serve Markdown files via endpoints (e.g., `/api/docs/{doc}`).
2. Example of Function Input:
   ```javascript
   module.exports = async function (context, req) {
     const docName = req.params.doc;
     const path = `src/content/docs/${docName}.md`;
     const content = await fs.promises.readFile(path, 'utf-8');
     context.res = {
       body: content,
       headers: {
         'Content-Type': 'text/markdown',
       },
     };
   };
   ```
3. Deploy the function using Azure pipelines.

---

## 3. YAML Metadata Enrichment
Each Markdown file in the `src/content/docs` directory should have YAML front matter metadata. This metadata should include:
   - `apiAccessible`: Specify if exposed through API.
   - Tags for indexing.
   - Modification dates.

Example Front Matter:
```yaml
---
title: Skills
description: Foundation of reusable task definitions.
apiAccessible: true
modificationDate: "2026-02-28T13:00:00Z"
tags: [skills, factory-engineering, tasks]
---
```

---

## 4. Using llms.txt for Agent Indexing
Azure hosted projects can include an `llms.txt` file to provide an index for LLMs (chatbots and agents). Place `llms.txt` at the repository root and list all accessible Markdown files:
  ```
  /docs/skills.md
  Title: Skills
  Description: Foundation of reusable task definitions.
  Modified: 2026-02-28
  Tags: skills, factory-engineering, tasks
  ```

---