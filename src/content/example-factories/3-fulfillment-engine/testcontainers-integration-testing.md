---
description: Guidelines for integration testing with Testcontainers. Use when writing tests that need real Kafka, PostgreSQL, or other infrastructure dependencies.
---

## Real dependencies, not mocks

Use Testcontainers to start actual infrastructure in tests. One container instance per type, shared across the test class:

```java
// ✅ Preferred: shared container started once per test class
@Testcontainers
@SpringBootTest
class OrderRepositoryTest {
    @Container
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void configure(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}

// ❌ Avoid: new container per test method — slow and wasteful
@Container
PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");
```

## Keep tests independent

Even though the container is shared, each test should set up and tear down its own data. Never rely on ordering or state from a previous test.
