---
description: Guidelines for writing LINQ queries using Entity Framework Core. Use when writing LINQ queries.
---

## Separate specification from execution

Always use query syntax (`from...select`) and separate IQueryable definition from async execution:

```csharp
// ✅ Preferred
var customersSpec =
    from customer in context.Customer
    where customer.CustomerGUID == customerGuid
    select new { customer.CustomerID, customer.Name };
var customers = await customersSpec.ToListAsync();

// ❌ Avoid: Method chaining with immediate execution
var customers = await context.Customer
    .Where(customer => customer.CustomerGUID == customerGuid)
    .Select(customer => new { customer.CustomerID, customer.Name })
    .ToListAsync();
```
