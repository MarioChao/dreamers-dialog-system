# Changelogs

## [v0.0.2] Format update + Small fixes | 2026/03/07

Updated the dialog GUI:
- Added `UIAspectRatioConstraint` with ratio of 1 for image labels.
- Adjusted the `UISizeConstraint` values for Entry_Button.

Changed dialog system & sequence formats:
- Sequences are now referenced by their id string:
    - .nextSequence -> nextSequenceId
    - .optionId_sequence -> optionId_sequenceId
- Added a constant sequence id `DialogConstants.CLOSE_SEQUENCE_ID` for closing dialogues.
    - This fixes the dialog closing early if the player spammed an option twice.
- Separated `setDialogSequenceForPlayer()` into two functions:
    - `storeDialogSequencesForPlayer()`: stores dialog sequences by their `sequenceId`s.
    - `setDialogSequenceIdForPlayer()`: shows the sequence with the given `sequenceId`.

Hopefully the new dialog sequence format is neater.

## [v0.0.1] Dreamer's dialog system | 2026/03/06

Made the server-sided dialog system (one module in `ReplicatedStorage`).

Made a sample script that displays a default test dialogue to every player that joined the game.
