---
description: Guidelines for defining Kafka event schemas and topic contracts. Use when creating new events, evolving existing schemas, or documenting topic ownership.
---

## Schema-first event design

Define the event schema before writing producer or consumer code. Every event must document its topic, key strategy, and payload fields:

```json
{
  "type": "record",
  "name": "OrderShipped",
  "namespace": "com.fulfillment.events",
  "fields": [
    { "name": "orderId", "type": "long" },
    { "name": "shippedAt", "type": { "type": "long", "logicalType": "timestamp-millis" } },
    { "name": "trackingNumber", "type": ["null", "string"], "default": null }
  ]
}
```

## Evolve schemas with backward compatibility

New fields must have defaults. Never remove or rename existing fields — add new ones and deprecate the old:

```json
// ✅ Preferred: add optional field with default
{ "name": "carrier", "type": ["null", "string"], "default": null }

// ❌ Avoid: renaming a field (breaks existing consumers)
// "shippingProvider" renamed to "carrier"
```
