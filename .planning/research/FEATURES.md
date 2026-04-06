# Feature Landscape

**Domain:** Todo App on Steroids
**Researched:** April 6, 2026

## Table Stakes

Features users expect. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Task Creation/Lists | Core function | Low | Basic CRUD for todo items. |
| Due Dates/Reminders | Reliability | Medium | Needs local notification support or polling. |
| Nested Tasks/Subtasks| "Steroid" feel | Medium | Standard for high-end todo apps. |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Visualization Dashboard | High-level overview | High | Interactive "nodes" or "graphs" to see task density and relationships. |
| Decision Frameworks | Structured thoughts | Medium | Built-in templates for WRAP (Widen options, Reality-test, Attain distance, Prepare to fail) or FORDEC. |
| Blog/Note Linkage | Context retention | Medium | Convert "tasks" into "long notes" or drafts seamlessly. |
| Decision Archive | Data-driven growth | Low | Keep track of past decisions and their outcomes to review habits. |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Real-time Collaboration | Over-engineering | Keep it local/single-user-first to focus on individual productivity. |
| Complex Cloud Sync | High infra cost | Local-first; perhaps simple file-based sync (Dropbox/GDrive) later. |

## Feature Dependencies

```
Task System -> Decision Framework (Linking decisions to actionable items)
Decision Framework -> Decision Archive (Archiving decisions for retrieval)
Note Editor -> Blog Post Drafts (Notes are the foundation for the blog posts)
```

## MVP Recommendation

Prioritize:
1. Core Todo CRUD with nested tasks.
2. WRAP decision framework integration.
3. Minimal Dashboard using GraphEdit to show task relations.

Defer: Blog post export/formatting (Focus on capturing first).

## Sources
- [WRAP Framework - Chip & Dan Heath "Decisive"](https://en.wikipedia.org/wiki/Decisive_(Heath_book))
- [Productivity Pattern Research]
