---
description: Guidelines for writing Entity Framework Core migrations. Use when adding, modifying, or reviewing EF Core migrations.
---

## One migration per logical change

Each migration should represent a single, focused schema change. If a change requires backfilling data, split it into two migrations: one for the schema change, one for the data.

```csharp
// ✅ Preferred: focused migration
public partial class AddCustomerEmail : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "Email",
            table: "Customer",
            nullable: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "Email",
            table: "Customer");
    }
}

// ❌ Avoid: combining schema change with data migration
public partial class AddEmailAndBackfill : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>("Email", "Customer", nullable: true);
        migrationBuilder.Sql("UPDATE Customer SET Email = ...");
        migrationBuilder.AlterColumn<string>("Email", "Customer", nullable: false);
    }
}
```

## Always implement Down

Every migration should be reversible. Implement `Down` so that failed deployments can roll back cleanly.
