---
description: Guidelines for extracting and composing React custom hooks. Use when encapsulating reusable state logic, side effects, or subscriptions.
---

## Extract shared logic into hooks

When two or more components share the same stateful logic, extract it into a custom hook. Each hook should do one thing:

```tsx
// ✅ Preferred: focused hook with clear contract
function useDebounce<T>(value: T, delayMs: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(id);
  }, [value, delayMs]);
  return debounced;
}

// ❌ Avoid: god hook that manages unrelated concerns
function useEverything() {
  const [search, setSearch] = useState("");
  const [cart, setCart] = useState([]);
  const [theme, setTheme] = useState("light");
  // ...hundreds of lines
}
```

## Hooks are testable units

Design hooks so they can be tested with `renderHook` in isolation. Avoid coupling hooks to specific UI components or global singletons.
