---
description: Guidelines for structuring React components using atomic design. Use when deciding component granularity, folder structure, or composition patterns.
---

## Build from atoms up

Compose UI from small, reusable pieces. Each level builds on the one below — atoms are indivisible, molecules combine atoms, organisms combine molecules:

```
components/
  atoms/       # Button, Input, Label, Icon
  molecules/   # SearchField (Input + Button), FormField (Label + Input)
  organisms/   # ProductCard, NavigationBar, CheckoutForm
  templates/   # PageLayout, DashboardLayout
  pages/       # HomePage, ProductDetailPage
```

## No one-off composite components

If a component is used in only one place and mixes multiple concerns, break it apart. Every molecule or organism should be independently meaningful:

```tsx
// ✅ Preferred: composable organisms
<ProductCard>
  <ProductImage src={product.image} />
  <ProductInfo name={product.name} price={product.price} />
  <AddToCartButton productId={product.id} />
</ProductCard>

// ❌ Avoid: monolithic blob
<ProductCardWithImageAndInfoAndCartButton product={product} />
```
