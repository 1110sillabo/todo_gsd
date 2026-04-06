# Research Summary: Todo App on Steroids

**Domain:** Productivity / PKM (Personal Knowledge Management)
**Researched:** April 6, 2026
**Overall confidence:** MEDIUM (Godot validation HIGH, Framework research MEDIUM)

## Executive Summary

The "Todo App on Steroids" is a hybrid project combining task management, structured decision-making (WRAP/FORDEC), and long-form note-taking (Blog Drafts). To support these visually intense and logic-heavy features, the **Godot Engine (4.3+)** is the recommended technology stack. Godot's powerful UI system (`Control` nodes) and flexible scene-tree architecture make it easier to build custom visualization dashboards (using `GraphEdit`) compared to traditional web or standard mobile frameworks like Flutter or React Native.

**SQLite** will serve as the local relational backend, chosen for its reliability in managing the complex links between tasks, decisions, and notes. The project will prioritize "local-first" storage to minimize latency and infrastructure overhead while allowing for future file-based sync extensions.

## Key Findings

**Stack:** Godot (4.5+) + GDScript + SQLite (via GDExtension). We use Godot 4.6 for development.
**Architecture:** Model-View-Controller (MVC) using Godot's Autoload for business logic and Signals for UI synchronization.
**Critical pitfall:** High risk that the "steroid" features (Visualization/Decision Frameworks) become "cool-but-useless" if not deeply integrated into the core task loop.

## Implications for Roadmap

Based on research, suggested phase structure:

1. **Phase 1: Foundation (Core Tasks)** - Focus on the basic CRUD operations using SQLite and building a robust list UI with Godot's `ItemList` or `VBoxContainer`.
   - Addresses: Table stakes (Task Lists, Subtasks).
   - Avoids: Pitfall 3 (Database Locking by establishing a solid DataManager early).

2. **Phase 2: Decision Hub (WRAP Framework)** - Implement the "Widen, Reality-test, Attain distance, Prepare" workflow as a separate scene that links to existing tasks.
   - Addresses: Differentiators (Decision-taking Framework).
   - Rationale: High value, moderate complexity, builds on Phase 1 data.

3. **Phase 3: Visualization Dashboard** - Use `GraphEdit` to visually display task nodes and dependencies.
   - Addresses: Differentiators (Visualization).
   - Rationale: Most complex visually; relies on a mature task database.

4. **Phase 4: Content Engine (Blog Post Drafts)** - Integrate a BBCode/Markdown-capable text editor that can "promote" notes to full drafts.

**Phase ordering rationale:**
- Build the data-gathering parts (Tasks/Decisions) first to have enough data for a meaningful visualization later.

**Research flags for phases:**
- Phase 3: Likely needs deeper research into `GraphEdit` performance with hundreds of nodes.
- Phase 4: Standard patterns, unlikely to need research (Godot's `RichTextLabel` is mature).

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Godot is exceptionally well-suited for complex UI and visual tools. |
| Features | MEDIUM | Broad feature list; exact detail of "Blog Post" needs more definition. |
| Architecture | HIGH | Godot's scene/signal system is a natural fit for this logic. |
| Pitfalls | MEDIUM | UX adoption of decision frameworks is always a risk (user-behavior-dependent). |

## Gaps to Address

- **Cloud Sync:** No current recommendation for cloud sync; will assume local-only for MVP.
- **Mobile Support:** Godot supports export, but the UI for a "Visualization Dashboard" on mobile will likely need a completely different scene/layout.
