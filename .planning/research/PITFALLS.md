# Domain Pitfalls

**Domain:** Todo App on Steroids (Productivity + Decisions)
**Researched:** April 6, 2026

## Critical Pitfalls

### Pitfall 1: Overly Complex Visualization (Graph Bloat)
**What goes wrong:** A simple list is always faster than a complex interactive graph. Users may find the visual dashboard "cool" but "useless."
**Prevention:** Make the dashboard actionable, not just a view. Allow clicking a node to edit a task or a link to create a dependency.

### Pitfall 2: Resource Reference Cycles
**What goes wrong:** `Resource A` references `Resource B` which references `Resource A` (e.g., in sub-tasks).
**Why it happens:** Attempting to build relational links like a database.
**Consequences:** Memory leaks, stack overflows, or serialization errors on save.
**Prevention:** Use ID strings for relational links instead of direct object reference where possible, or use IDs as keys in a task dictionary.

### Pitfall 3: Mobile Storage Config (res vs user)
**What goes wrong:** Saving files directly in `res://` instead of `user://`.
**Why it happens:** Developer testing in editor vs export environment.
**Consequences:** App crashes or persistent data loss on mobile.
**Prevention:** Always use the `user://` prefix for writable data.

## Moderate Pitfalls

### Pitfall 1: Text Editor Limitations
**What goes wrong:** `TextEdit` in Godot is highly efficient for large text but lacks built-in WYSIWYG for "Blog Post Drafts."
**Prevention:** Use a light Markdown-to-BBCode parser or a custom `TextEdit` wrapper.

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Tasks | Graph Node Spam | Limit total visible nodes in GraphEdit; use levels-of-detail. |
| Blog Box | TextEdit Bloat | Lazy-load long drafts from separate `.tres` files instead of one giant blog collection. |
| Decisions | orphaned sub-resources | Ensure deletions clean up sub-resources to avoid storage bloat. |

## Sources
- [User Experience Research - Personal Knowledge Management Tools (PKM)]
- [Godot Engine Issue Tracker - UI Performance]
