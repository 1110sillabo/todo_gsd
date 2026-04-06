# Development Journal: Todo App on Steroids

## Project Metadata
- **Engine:** Godot 4.6 (Forward Mobile)
- **Platforms:** Mobile (iOS/Android), Desktop (macOS/Linux)
- **Architecture:** 3-Box Isolated (Tasks, Blogs, Decisions)
- **Storage:** Native Godot Resources (`.tres`)

---

## 📅 2026-04-06: The Foundation & Visual Pivot

### Primary Goals
- Initialize GSD workflow and project structure.
- Define the data model and storage strategy.
- Implement the "TaskBox" visual dashboard.

### Key Decisions
1. **Decision: Pivot from SQLite to Godot Resources (`.tres`)**
    - **Context:** Initially planned SQLite for relational data.
    - **Rationale:** The user requested 3 isolated "boxes" (Tasks, Blogs, Decisions) with no internal relationships. Godot Resources are native, faster to implement, and easier to debug on mobile.
2. **Decision: GDScript Only**
    - **Context:** Clarified the stack to avoid C/C++ overhead.
    - **Rationale:** Maximizes productivity and ensures seamless mobile exports.
3. **Decision: Testing Strategy**
    - **Context:** Use a "Testing-first" approach similar to Godotneers.
    - **Rationale:** Implemented **GdUnit4** stubs and tests for core logic to ensure stability before UI work.

### Progress Timeline
- ✅ **Phase 1: Foundation**
    - Created `TaskResource.gd` with title, creation timestamps, deadline tracking, and spatial `graph_position`.
    - Created `PersistenceManager.gd` for automatic `.tres` saving/loading from `user://tasks/`.
    - Added unit tests for Task creation, rescheduling, and serialization.
- ✅ **Phase 2: TaskBox Visuals**
    - Developed `TaskBox.tscn` (GraphEdit) and `TaskNode.tscn` (GraphNode).
    - Implemented "Persistence Bridge": dragging nodes in the UI automatically saves their position to disk.
    - Fixed **Bug #01**: `ERR_CANT_OPEN (19)` on macOS due to directory creation timing (fixed by moving logic to `_init()`).

### Known Issues / Technical Debt
- **UI Feedback:** `TaskNode` doesn't currently display the `title` or `description` in the UI scene; it only syncs the data. (Next priority: UI polishing).
- **Addon Initialization:** GdUnit4 needs to be manually enabled in the Godot Editor after first setup.

---

## ⏭️ Next Up: Phase 3
- **Objective:** BlogBox implementation.
- **Focus:** `TextEdit` for long-form notes and `FileAccess` for exporting drafts to `.md` files.
