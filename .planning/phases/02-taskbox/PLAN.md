## Phase 2: TaskBox Visuals
**Goal:** Create a visual, node-based task dashboard using Godot's GraphEdit.

### REQUIREMENTS
- [R01] Implement `TaskNode` (GraphNode) to represent a `TaskResource`.
- [R02] Implement `TaskBox` (GraphEdit) to manage and display multiple `TaskNode`s.
- [R03] Synchronize spatial data (`graph_position`) from the UI back to the `.tres` file.
- [R04] UI Integration tests using GdUnit4 SceneRunner to verify adding/moving tasks.

### PLAN
- **Wave 1**: TaskNode & TaskBox Scene Implementation.
- **Wave 2**: Persistence bridge (Loading existing tasks into the Graph).
- **Wave 3**: UI Integration Tests (Verifying interaction).
