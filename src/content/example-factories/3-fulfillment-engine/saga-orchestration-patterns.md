---
description: Guidelines for implementing saga orchestration in distributed systems. Use when coordinating multi-step transactions across services that require compensating actions on failure.
---

## Explicit state machine with compensation

Model each saga as a state machine. Every forward step has a corresponding compensating action. Never rely on distributed locks:

```java
// ✅ Preferred: clear states and compensations
public enum OrderSagaState {
    STARTED, PAYMENT_RESERVED, INVENTORY_RESERVED, CONFIRMED, COMPENSATING, FAILED
}

public class OrderSaga {
    void onPaymentReserved() { state = PAYMENT_RESERVED; reserveInventory(); }
    void onInventoryFailed() { state = COMPENSATING; releasePayment(); }
}

// ❌ Avoid: ad-hoc try/catch without state tracking
try {
    reservePayment();
    reserveInventory();
    confirm();
} catch (Exception e) {
    // unclear which steps succeeded — can't compensate reliably
}
```

## Idempotent steps

Every saga step and compensation must be idempotent. Use unique request IDs so retries and replays produce the same result.
