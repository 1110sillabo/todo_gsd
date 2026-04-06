# Technology Stack

**Project:** Todo App on Steroids
**Researched:** April 6, 2026

## Recommended Stack

### Core Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Godot Engine | 4.6 | Frontend & Logic | Extreme flexibility for standard UI and custom visualizations. Scene system is perfect for "steroid" features. |
| GDScript | 4.6 | Scripting | High performance for UI logic, easy to iterate for custom frameworks and complex data flows. |

### Storage
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Godot Resources (`.tres`) | 4.6 | Local Data Storage | Excellent for isolated, object-oriented data. Support for simple relationships, built-in serialization, and no external dependencies. |
| FileAccess | Core | Export/Import | Robust native API for handled .md and .csv generation. |

### Supporting Libraries
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Godot-GraphEdit | Core | Visualization | To build the visualization dashboard/nodes. |
| TextEdit | Core | Blog/Note Editor | Handles large text blocks with high efficiency in Godot 4.6. |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Frontend | Godot | Flutter | Godot offers better "canvas" control for advanced visualizations (GraphEdit). |
| Storage | Godot Resources | SQLite | SQLite is overkill for isolated sections with low relational complexity. Resources are simpler to manage on mobile. |

## Installation

```bash
# No npm install needed for Godot core, but ensure 4.3+ is available.
# Recommendation: Use a Godot-SQLite GDExtension or wrapper.
```

## Sources
- [Godot UI Documentation](https://docs.godotengine.org/en/stable/tutorials/ui/index.html)
- Community patterns for Godot non-game apps.
