# Architecture Patterns

**Domain:** Todo App on Steroids
**Researched:** April 6, 2026

## Recommended Architecture

Godot follows a **Scene-Tree-based Component Architecture**. For a productivity app, we'll lean into a **Model-View-Viewmodel (MVVM)**-like structure via Godot signals.

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `DataManager` | SQLite interface (Singleton/Autoload) | `ListController`, `DecisionManager` |
| `ListUI` | Basic Todo lists, nested items | `DataManager` for I/O, `TaskDetail` for focus. |
| `Visualizer` | Graph/Canvas to show task clusters | `DataManager` to get nodes/links. |
| `DecisionHub` | Step-by-step framework UI (WRAP) | `DataManager` to save decisions and associated todos. |
| `NoteEngine` | Long-form RickTextEditor | `DataManager` to link notes to tasks. |

### Data Flow

```mermaid
DataManager <- [Signals] -> Controllers -> Views (UI Nodes)
                ^
                |
             SQLite DB
```

## Patterns to Follow

### Pattern 1: Autoload for Business Logic
**What:** Define a Global script (`G.gd`) for shared data access.
**When:** Need to update todos from both the List and the Visualizer concurrently.
**Example:**
```gdscript
# G.gd (Autoloaded)
signal task_updated(task_id)

func update_task(task_id, data):
    # Update SQLite
    emit_signal("task_updated", task_id)
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Deep Nested Scripts
**What:** Writing logic for task updates deep inside the UI node (e.g., in a `Button.gd`).
**Why bad:** Makes the visualizer difficult to keep in sync.
**Instead:** Emit custom signals that the `DataManager` or a controller handles.

## Scalability Considerations

| Concern | 100 tasks | 1K tasks | 10K+ tasks |
|---------|-----------|----------|------------|
| Render Perf | OK | OK (Godot UI is fast) | Use `ScrollContainer` with virtualized or limited list visibility. |
| DB Search | OK | Index SQLite fields | Use full-text search indexing for notes. |

## Sources
- [Architecture for Godot Non-Game Apps]
- [MVVM in Godot using Signals]
