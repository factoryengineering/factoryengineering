---
description: Guidelines for building Razor Pages in ASP.NET Core. Use when creating or editing page models, handlers, and views.
---

## Page model owns the logic

Keep the `.cshtml` file focused on markup. All data loading, validation, and business logic belong in the `PageModel`:

```csharp
// ✅ Preferred: logic in the page model
public class EditModel : PageModel
{
    [BindProperty]
    public CustomerInput Input { get; set; }

    public async Task<IActionResult> OnPostAsync()
    {
        if (!ModelState.IsValid) return Page();
        await service.UpdateCustomer(Input);
        return RedirectToPage("./Index");
    }
}

// ❌ Avoid: logic in the view
@if (Model.Customer != null && Model.Customer.IsActive && ...)
{
    // complex branching in cshtml
}
```

## Use tag helpers over raw HTML helpers

Tag helpers read like HTML and integrate with model binding and validation automatically:

```html
<!-- ✅ Preferred -->
<input asp-for="Input.Name" />
<span asp-validation-for="Input.Name"></span>

<!-- ❌ Avoid -->
@Html.TextBoxFor(m => m.Input.Name)
@Html.ValidationMessageFor(m => m.Input.Name)
```
