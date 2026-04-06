# Workflow and Architecture

## Repository architecture

This repository is currently a lightweight workspace for Godot/GDScript development:

- `.devcontainer/` — container configuration for Node/GSD tooling and VS Code extension support
- `.vscode/` — editor settings, extension recommendations, and tasks
- `workflow.md` — workflow guidance for this project

## Development flow

### 1. Terminal-first work

Start in the terminal for coding and local operations:

- run `gsd` or `npx get-shit-done-cc` commands locally
- use `git status` and `git diff` to inspect changes
- keep business logic in GDScript and engine glue in Godot scenes/resources

### 2. VS Code for coding and local agent help

Use VS Code with these extensions:

- `GodotEngine.godot-tools` for Godot project support
- `GitHub.copilot-chat` for AI-assisted code review, suggestions, and GDScript help

The local task `Review diff with RoboRev/Copilot` is configured in `.vscode/tasks.json`.

### 3. Godot Engine for UI, visuals, and testing

Open the project in the Godot editor for:

- scene editing, visual layout, and UI design
- running tests and previewing gameplay
- validating exported resources and imported assets

### 4. Terminal review loop

After using Godot:

- inspect the actual files with `git diff` or `git diff --stat`
- use the VS Code task to run `roborev` if installed
- continue editing in GDScript and re-run Godot as needed

## Agent-enabled review workflow

If you want a lightweight agent-driven loop without PRs:

1. Write or update code in VS Code with Copilot Chat active.
2. Run the VS Code task `Review diff with RoboRev/Copilot`.
3. If `roborev` is installed, it will attempt a local review command.
4. Otherwise, the task falls back to showing a Git diff summary.
5. Use Copilot Chat on the diff or open files for targeted feedback.

## RoboRev configuration

- Install RoboRev globally on macOS or inside the container:
  - `npm install -g roborev`
- Verify installation with:
  - `roborev --version`
- The VS Code task uses:
  - `roborev review --local .`
- If RoboRev is not available, the task falls back to a Git diff summary.
- If you rebuild the devcontainer, the container will install RoboRev automatically via `postCreateCommand`.

## Notes on RoboRev and local review

- `roborev` is best used if it supports a local review mode; the task checks for it and otherwise uses `git diff`.
- This avoids needing PRs while still giving you a review step in the terminal.
- You can extend the task later with a custom script or alias if your flow becomes more elaborate.

## Running the review task

- In VS Code, press `Cmd+Shift+P` and choose `Tasks: Run Task`.
- Select `Review diff with RoboRev/Copilot`.
- The task will run RoboRev if installed, else show `git diff --stat`.
- You can also run manually from the terminal:
  - `roborev review --local .`
  - `git diff --stat`

## Local VS Code / Godot settings

- `.vscode/settings.json` sets the local Godot executable path for macOS bundles.
- `.vscode/extensions.json` recommends the Godot tools and Copilot Chat extensions.

## Container note

The devcontainer is kept for tooling and extension support, but the Godot executable is expected to run locally on macOS, not inside the container.
