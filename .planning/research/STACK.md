# Technology Stack

**Project:** Todo App on Steroids
**Researched:** April 6, 2026

## Recommended Stack

### Core Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Godot Engine | 4.6 | Frontend & Logic | Extreme flexibility for standard UI and custom visualizations. Scene system is perfect for "steroid" features. |
| GDScript | 4.6 | Scripting | High performance for UI logic, easy to iterate for custom frameworks and complex data flows. |

### Database
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| SQLite | 3.x | Local Data | Robust, handles relational data (todos <-> decisions <-> notes) perfectly for a desktop/mobile app. |
| Godot-SQLite | GDExtension | DB Binding | Native performance for Godot-SQLite integration. |

### Supporting Libraries
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Godot-GraphEdit | Core | Visualization | To build the visualization dashboard/nodes. |
| RichTextLabel | Core | Blog/Note Editor | Handles long-form notes with BBCode/Markdown support. |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Frontend | Godot | Flutter | Godot offers better "canvas" control for advanced visualizations and simpler state-to-scene mapping for custom components. |
| Storage | SQLite | JSON Files | JSON lacks relational querying which will be needed for the decision-to-todo links. |

## Installation

```bash
# No npm install needed for Godot core, but ensure 4.3+ is available.
# Recommendation: Use a Godot-SQLite GDExtension or wrapper.
```

## Sources
- [Godot UI Documentation](https://docs.godotengine.org/en/stable/tutorials/ui/index.html)
- Community patterns for Godot non-game apps.
