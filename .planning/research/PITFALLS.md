# Domain Pitfalls

**Domain:** Todo App on Steroids (Productivity + Decisions)
**Researched:** April 6, 2026

## Critical Pitfalls

### Pitfall 1: Overly Complex Visualization (Graph Bloat)
**What goes wrong:** A simple list is always faster than a complex interactive graph. Users may find the visual dashboard "cool" but "useless."
**Prevention:** Make the dashboard actionable, not just a view. Allow clicking a node to edit a task or a link to create a dependency.

### Pitfall 2: Decision Paralysis in the Framework
**What goes wrong:** The WRAP or FORDEC process feels like "too much work" for small tasks.
**Prevention:** Offer "Mini-Decision" vs "Full-Decision" templates. Don't force every todo into a framework.

### Pitfall 3: Database Locking (Desktop/Mobile Sync)
**What goes wrong:** Godot doesn't handle SQLite locking across multiple processes well.
**Prevention:** Ensure a single DataManager script handles all database connections and that it closes gracefully.

## Moderate Pitfalls

### Pitfall 1: Text Editor Limitations
**What goes wrong:** `TextEdit` or `CodeEdit` nodes in Godot are excellent but lack standard Rich Text formatting features (Bold/Italic/Images) expected for a "Blog Post Draft."
**Prevention:** Use `RichTextLabel` with a custom `TextEdit` wrapper that handles BBCode conversion or consider a light Markdown-to-BBCode parser.

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Core List | Deep Nesting UI bugs | Use simple recursive UI components with limits on depth. |
| Dashboard | Performance lags | Only render visible nodes in the GraphEdit or use simple sprites for large scales. |
| Decisions | Low adoption | Start with very small, 3-question templates. |

## Sources
- [User Experience Research - Personal Knowledge Management Tools (PKM)]
- [Godot Engine Issue Tracker - UI Performance]
