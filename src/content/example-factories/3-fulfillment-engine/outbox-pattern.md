**Core Principles**
- Write event to outbox in same transaction as state.
- Separate process publishes to Kafka.

**Examples**
- Outbox table; poll or CDC to publish; at-least-once.
