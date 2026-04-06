# Architecture Patterns

**Domain:** Todo App on Steroids
**Researched:** April 6, 2026

## Recommended Architecture

Godot follows a **Scene-Tree-based Component Architecture**. The "Isolated 3-Box" model uses a **Service-Oriented Singleton** approach for data persistence while keeping visual logic decoupled.

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `PersistenceService` | Saving/Loading `.tres` files | `Tasks`, `Blog`, `DecisionLog` |
| `TaskBox` | Visualized Task clusters (GraphEdit) | `PersistenceService` |
| `BlogBox` | Long-form note editor (TextEdit) | `PersistenceService` |
| `DecisionBox` | Framework-driven logging | `PersistenceService` |
| `ExportService` | String-templating to `.md` / `.csv` | All Box Controllers |

### Data Flow

```mermaid
[UI Box] <--> [Data Object (Resource)] <--> [PersistenceService] <--> [.tres Files]
   |
   +-----> [ExportService] ----> [.md / .csv Downloads]
```

## Patterns to Follow

### Pattern 1: Dedicated Resource Classes
**What:** Define a `TaskResource.gd`, `DraftResource.gd`, and `DecisionResource.gd` inheriting `Resource`.
**When:** To ensure strict type-safety and automatic serialization in the Inspector.
**Example:**
```gdscript
# TaskResource.gd
class_name TaskResource
extends Resource

@export var title: String = ""
@export var is_done: bool = false
@export var links: Array[TaskResource] = []
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Cross-Box Coupling
**What:** Having a `TaskResource` hold a reference to a `DraftResource`.
**Why bad:** Violates the "Isolated" requirement and makes data-corruption recovery harder.
**Instead:** Rely on unique identifiers or simple string-based tags if soft-links are absolutely necessary.

## Scalability Considerations

| Concern | 100 entries | 1K entries | 10K+ entries |
|---------|-------------|------------|--------------|
| Memory | Negligible | OK | Consider loading boxes on-demand (lazy-loading). |
| File I/O | Instant | Fast | Binary serialization (.res) instead of text (.tres) if lag occurs. |
| Export | Background task | Background task | Implementation of a dedicated Thread for export logic. |

## Sources
- [Architecture for Godot Non-Game Apps]
- [MVVM in Godot using Signals]
