---
description: Guidelines for instrumenting Spring Boot services with Micrometer metrics and distributed tracing. Use when adding timers, counters, or trace propagation.
---

## Low-cardinality tags only

Every metric must use bounded tag values. Never use user IDs, request IDs, or other unbounded values as tags:

```java
// ✅ Preferred: bounded tag values
registry.counter("orders.created", "region", order.getRegion()).increment();

// ❌ Avoid: high-cardinality tag — explodes metric storage
registry.counter("orders.created", "orderId", order.getId().toString()).increment();
```

## Correlate logs with trace IDs

Configure log patterns to include the trace and span IDs automatically. Every log line in a request should be traceable to its distributed context:

```properties
# application.properties
logging.pattern.level=%5p [${spring.application.name},%X{traceId},%X{spanId}]
```
