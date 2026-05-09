# Main entities

There are two basic artifacts:

1. todos
2. notes (like blog posts)

# UI

Add 3 dots verticals icon on the top right. On open there are 3 options:
1. send json (does nothing for the moment, will later be used to send a json abckup via email);
2. stats (does nothing for the moment, will go to the visualizations one we have it);
3. quit (exit the app).

# Tasks UI

1. task are listed in 3 groupds: expired (scadute), todo (da fare), completed (completate).
Each list is display with a dropdown, opened by default.
The competed ones are instead hidden.

2. the single tasks are are displayed on two stacked items:
- task title/content
- task deadline. User can edit the schedule by clicking on a calendar icon and opening picking a new deadline

# Main tasks item and note item interface

- can add task
- can edit tasks (including deadline)
- can shuffle/re order tasks

- can add note. A note is a title + content.
- on click on a note, open a textbox to write into
- notes have no deadline

# Later developments

- keep a changelog for tasks: how many time are they rescheduled?
- organize notes into collections (more notes sharing a theme)
- add a wrapped like functionality