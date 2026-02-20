---
description: Guidelines for structuring Spring Boot services. Use when creating a new service, defining its API boundary, or configuring health checks and profiles.
---

## One bounded context per service

Each Spring Boot application owns exactly one bounded context. Expose a clear API (REST or messaging) and never reach directly into another service's database:

```java
// ✅ Preferred: service with a clear domain boundary
@SpringBootApplication
public class OrderServiceApplication { }

@RestController
@RequestMapping("/api/orders")
class OrderController {
    private final OrderService orderService;
    // endpoints scoped to the Order bounded context
}

// ❌ Avoid: one service reaching into another's schema
@Repository
interface InventoryRepository extends JpaRepository<InventoryItem, Long> { }
// InventoryItem belongs to a different service — use an API call instead
```

## Health checks and configuration

Always define a health indicator and externalize configuration with `@ConfigurationProperties`. Use Spring profiles for environment-specific settings, not conditionals in code.
