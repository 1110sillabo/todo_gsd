# Feature Landscape

**Domain:** Todo App on Steroids (Isolated 3-Box)
**Researched:** February 2025
**Overall status:** Updated for Resource-based 3-Box architecture

## Table Stakes

Features users expect in each box. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Box |
|---------|--------------|------------|-----|
| **Task Nodes** | Visual task tracking via GraphEdit. | High | TaskBox |
| **Markdown Editing** | Drafting long-form blog content with TextEdit. | Medium | BlogBox |
| **Decision Logging** | Chronological record of key project decisions. | Low | DecisionBox |
| **Local Auto-save** | Native Godot ".tres" serialization on change. | Low | Persistence |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Box |
|---------|-------------------|------------|-----|
| **Visual Clusters** | Group nodes in GraphEdit for brain-mapping tasks. | Medium | TaskBox |
| **Markdown Export** | One-tap "FileAccess" export for blog drafts. | Low | BlogBox |
| **CSV History** | Easy historical analysis of all decision logs. | Low | DecisionBox |
| **Soft-Tagging** | Simple string-based tags (no code linking between boxes). | Low | Global |

## Anti-Features

Features to explicitly NOT build to maintain isolation.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **Shared Pointers** | Resource references between boxes (too complex). | Use string tags/IDs. |
| **Full Relational DB** | SQLite is overkill for isolated data boxes. | Godot Resource files (.tres). |
| **Cross-Box UI** | Mixing task UI with blog editor (clutters phone screen). | 3 distinct UI "Tabs" or "Screens". |

## Feature Dependencies

```
PersistenceService (Resource Base) -> Task Resource
PersistenceService (Resource Base) -> Blog Resource
PersistenceService (Resource Base) -> Decision Resource
Task Resource -> GraphEdit Canvas Logic
Blog Resource -> Markdown Export Logic
Decision Resource -> CSV Export Logic
```

## MVP Recommendation

Prioritize (Phase 1/2 focus):
1. **Task Canvas:** Basic "GraphNode" creation and position saving.
2. **Blog Drafts:** Simple "TextEdit" with persistent string storage.
3. **Decision Log:** Append-only log with a simple data grid or list.

Defer:
- **Advanced Graph Visuals:** Complex node connections can wait.
- **Rich Text Highlighting:** BBCode/Syntax coloring for drafts.

## Sources

- [Godot 4.3+ TextEdit official docs](https://docs.godotengine.org/en/stable/classes/class_textedit.html)
- [Godot FileAccess class](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html)
- [Research into isolated vs relational storage patterns (2025)](https://docs.godotengine.org/en/stable/tutorials/io/resources.html)
