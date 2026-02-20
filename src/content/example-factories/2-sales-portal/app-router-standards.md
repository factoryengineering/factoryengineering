---
description: Guidelines for Next.js App Router conventions. Use when creating routes, layouts, loading states, or choosing between server and client components.
---

## Server components by default

Every component is a server component unless it needs browser APIs or interactivity. Only add `"use client"` when the component uses hooks, event handlers, or browser-only APIs:

```tsx
// ✅ Preferred: server component fetches its own data
export default async function CustomersPage() {
  const customers = await getCustomers();
  return <CustomerList customers={customers} />;
}

// ❌ Avoid: unnecessary client component for static rendering
"use client";
export default function CustomersPage() {
  const [customers, setCustomers] = useState([]);
  useEffect(() => { fetchCustomers().then(setCustomers); }, []);
  return <CustomerList customers={customers} />;
}
```

## Colocate data fetching with the route segment

Fetch data in the `page.tsx` or `layout.tsx` that needs it, not in a parent that passes it down. Use `loading.tsx` for Suspense boundaries at each route segment.
