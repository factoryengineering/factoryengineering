---
title: Build Your Own Software Factory
description: Workshop resources for Build Your Own Software Factory — repositories, clone commands, and skill install commands.
---

Welcome to the **Build Your Own Software Factory** workshop. Everything you need for the session is linked below.

## Demo application

[github.com/factoryengineering/demo](https://github.com/factoryengineering/demo)

Festify, an event ticketing API built with ASP.NET Core and Entity Framework Core, with a Blazor UI. It requires the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).

```bash
git clone https://github.com/factoryengineering/demo.git
```

## Skill evaluation framework

[github.com/factoryengineering/eval](https://github.com/factoryengineering/eval)

A TypeScript framework that ablates a skill one line at a time and measures, across models, which lines are load bearing.

```bash
git clone https://github.com/factoryengineering/eval.git
```

## Factory Engineering skills

[github.com/factoryengineering/skills](https://github.com/factoryengineering/skills)

The night-shift skills that let a scheduled agent work a queue of labelled issues while nobody is watching. Install them into your project:

```bash
npx openskills install factoryengineering/skills
```

## Michael L. Perry's skills

[github.com/michaellperry/skills](https://github.com/michaellperry/skills)

Skills I install into the repositories I work in. Install them into your project:

```bash
npx openskills install michaellperry/skills
```

This includes the [degrees-of-freedom constitution](https://github.com/michaellperry/skills/tree/main/skills/degrees-of-freedom): a representation is faithful to its problem when its degrees of freedom equal the dimensionality of the problem, no more and no fewer. A repository adopts it by naming it as authority, and its issues then cite articles by number.

## Keep going

- [What is a Software Factory?](/getting-started/introduction/overview)
- [Your First Skill in 5 Minutes](/getting-started/quick-start)
- [Articles](/articles)
