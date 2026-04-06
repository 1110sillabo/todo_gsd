# Research Summary: Todo App on Steroids

**Domain:** Productivity / PKM (Personal Knowledge Management)
**Researched:** April 6, 2026
**Overall confidence:** MEDIUM (Godot validation HIGH, Framework research MEDIUM)

## Executive Summary

The "Todo App on Steroids" is a hybrid project combining task management, structured decision-making (WRAP/FORDEC), and long-form note-taking (Blog Drafts). To support these visually intense and logic-heavy features, the **Godot Engine (4.3+)** is the recommended technology stack. Godot's powerful UI system (`Control` nodes) and flexible scene-tree architecture make it easier to build custom visualization dashboards (using `GraphEdit`) compared to traditional web or standard mobile frameworks like Flutter or React Native.

**Godot Resources (`.tres`)** are the recommended alternative to SQLite. Since the 3 main sections (Tasks, Blog, Decision Log) are isolated with no internal code dependencies, the relational overhead of a database is unnecessary. Resources provide native serialization, easy versioning, and excellent performance for mobile (Godot 4.6).

## Key Findings

**Stack:** Godot (4.6) + GDScript + Godot Resources.
**Architecture:** Isolated "3-Box" model with a centralized `PersistenceService` using `.tres` files.
**Critical pitfall:** Risk of building complex relationships between boxes later; must enforce the "Isolated" rule for simplicity.

## Implications for Roadmap

Based on research, suggested phase structure:

1. **Phase 1: Foundation (Resources & Persistence)** - Establish the `PersistenceService` and the 3 base resource classes.
   - Addresses: 3-Box baseline.

2. **Phase 2: Task Visualizer (GraphEdit)** - Build the interactive task cluster nodes.
   - Addresses: Visual Table Stakes.

3. **Phase 3: Blog Box & Export Logic** - Implement the `TextEdit` drafting system and `FileAccess`-based Markdown export.
   - Addresses: Content creation & Portability.

4. **Phase 4: Decision Log & Analysis** - Create the logic-driven logging system for history and future CSV export.
   - Rationale: Most straightforward, relies on a stable persistence layer.

**Phase ordering rationale:**
- Establish storage first to ensure all 3 boxes can save data before specializing their UI.

**Research flags for phases:**
- Phase 2: Performance of many GraphEdit nodes on mobile devices.
- Phase 3: TextEdit cursor behavior on high-res mobile displays.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Godot Resources are a perfect fit for isolated personal tools. |
| Features | HIGH | Requirements are now clearly bounded into distinct boxes. |
| Architecture | HIGH | Service-based architecture ensures zero coupling between boxes. |
| Pitfalls | MEDIUM | User education on "Isolated" vs "Linked" might be needed. |

## Gaps to Address

- **Cloud Sync:** No current recommendation for cloud sync; will assume local-only for MVP.
- **Mobile Support:** Godot supports export, but the UI for a "Visualization Dashboard" on mobile will likely need a completely different scene/layout.
