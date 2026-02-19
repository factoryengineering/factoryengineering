**Core Principles**
- Prefer declarative LINQ; avoid N+1.
- Use async when querying (ToListAsync, etc.).

**Examples**
- Project only needed columns; filter in DB.
