---
description: Guidelines for implementing the transactional outbox pattern. Use when publishing domain events to Kafka while guaranteeing consistency with the local database.
---

## Write event and state in one transaction

Insert the domain event into an outbox table inside the same database transaction that modifies state. A separate process reads the outbox and publishes to Kafka:

```java
// ✅ Preferred: single transaction for state + outbox
@Transactional
public void completeOrder(Long orderId) {
    Order order = orderRepository.findById(orderId).orElseThrow();
    order.markCompleted();
    orderRepository.save(order);

    outboxRepository.save(new OutboxEvent(
        "order.completed", orderId.toString(), serialize(order)));
}

// ❌ Avoid: publishing directly — if Kafka is down, state and events diverge
@Transactional
public void completeOrder(Long orderId) {
    order.markCompleted();
    orderRepository.save(order);
    kafkaTemplate.send("order.completed", serialize(order)); // not transactional
}
```

## At-least-once delivery

The outbox publisher guarantees at-least-once delivery. Consumers must be idempotent — use event IDs to deduplicate.
