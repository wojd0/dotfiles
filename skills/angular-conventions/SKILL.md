---
name: angular-conventions
description: Angular conventions. Use when you edit Angular .ts or .html files, write or run Angular unit tests, or change localization files.
---

# Angular conventions

## Components and classes

When you update an Angular .ts file, remove the `standalone: true` flag if it is still there. Angular no longer needs it.

## Localization

Edit only `en.json`. Leave the files for all other languages unchanged.

## Unit tests

Before you write or change a unit test, read [references/unit-testing.md](references/unit-testing.md). Apply every rule in it.
