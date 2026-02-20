---
description: Guidelines for writing FluentMigrator migrations. Use when adding or modifying database schema through FluentMigrator in .NET projects.
---

## One migration per change, always reversible

Each migration class handles a single schema change. Always implement both `Up` and `Down` so deployments can roll back:

```csharp
// ✅ Preferred: focused and reversible
[Migration(20260115_0001)]
public class AddCustomerRegion : Migration
{
    public override void Up()
    {
        Alter.Table("Customer").AddColumn("Region").AsString(50).Nullable();
    }

    public override void Down()
    {
        Delete.Column("Region").FromTable("Customer");
    }
}

// ❌ Avoid: multiple unrelated changes in one migration
[Migration(20260115_0002)]
public class MixedChanges : Migration
{
    public override void Up()
    {
        Alter.Table("Customer").AddColumn("Region").AsString(50).Nullable();
        Create.Table("AuditLog").WithColumn("Id").AsInt64().PrimaryKey();
        Delete.Column("LegacyFlag").FromTable("Orders");
    }
}
```

## Use descriptive, timestamped names

Name migration classes to describe the change (e.g., `AddCustomerRegion`). Use a timestamp-based version number to avoid ordering conflicts across branches.
