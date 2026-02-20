---
description: Guidelines for Spring Data JPA repository design. Use when writing repositories, queries, or projections against JPA entities.
---

## Repository per aggregate root

Define one repository per aggregate root, not per table. Avoid exposing child entities through their own repositories:

```java
// ✅ Preferred: repository for the aggregate root only
interface OrderRepository extends JpaRepository<Order, Long> {
    @Query("SELECT o FROM Order o JOIN FETCH o.lineItems WHERE o.id = :id")
    Optional<Order> findWithLineItems(@Param("id") Long id);
}

// ❌ Avoid: separate repository for a child entity
interface OrderLineItemRepository extends JpaRepository<OrderLineItem, Long> { }
```

## Prevent N+1 queries

Use `JOIN FETCH`, `@EntityGraph`, or projections to load associations in a single query. Never rely on lazy loading inside a loop:

```java
// ✅ Preferred: fetch association eagerly in the query
@EntityGraph(attributePaths = "lineItems")
List<Order> findByCustomerId(Long customerId);

// ❌ Avoid: lazy loading triggered per iteration
orders.forEach(order -> order.getLineItems().size());
```
