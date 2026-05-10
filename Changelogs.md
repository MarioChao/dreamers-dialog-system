# Changelogs

## [v0.0.9] Graphemes + Optimizations + Race condition | 2026/05/09

Updated `TextTypewriter` to a newer version that operates on graphemes.

Removed pauses on space characters.

When storing new dialog sequences in `MainServer`, the old sequences for the player are now cleared.

Slightly fixed weird behavior when showing multiple dialog sequences at the same time (`MainClient`).
- Used `onShowDialogEntryProxy()` to ensure methods run in at most one thread at a time.
- Existing threads are cancelled to allow the newest one to run, avoiding blocking.

Moved `ServerScriptService` folder to be under the new `TestPlace` folder.

Factored out code for interfacing `DialogSystem` and `DialogStorage` from the `DialogMain` script to the `DialogActions` module.
- Added a method to `DialogActions` to set dialog using the name of the sequences module in `DialogStorage`.

Added support for checking if player is currently in a dialog.
- Added new `getIsPlayerInDialog()` method to `DialogSystem`.
- Added the `willOverwriteExisting` parameter to the new method in `DialogActions`.

## [v0.0.8] Updated typewriter | 2026/05/07

Factored out typewriting code from `MainClient` into the [TextTypewriter](https://github.com/MarioChao/text-typewriter) module.
- Added pause delays for punctuations.
- Added sound effects while writing characters.
- Added a customizable callback while writing characters.

Slightly updated the `DialogEntry` type.
- `options` field is moved to the new `optionsData` field.
- New `typewriterData` fields for `textData` and `optionsData`.

Slightly updated `MainServer`.
- Fixed a memory leak when player leaves.
- Made some small code cleaner.

## [v0.0.7] globIgnorePaths + Wally lock | 2026/05/06 (2)

Re-added global ignore paths of `**/wally.toml` to the main `default.project.json`.

Removed `wally.lock` from `.gitignore`, effectively committing it.

## [v0.0.6] Wally refactoring + Dialog info + License | 2026/05/06 (1)

Refactored the overall file structure.
- Added support for "Wally packaging" while keeping "Rojo place syncing" and "Luau autocomplete".
    - Main `default.project.json` in root folder for Rojo place syncing & Luau autocomplete.
    - `wally.toml` and a secondary `default.project.json` in `src` folder for Wally packaging.
- Changed `src/ReplicatedStorage/Modules/DialogSystem` to just `src/DialogSystem`.
- Modified `MainClient` and `MainServer` so dependencies are referenced using parent-child relationships.
    - Previously, the dependencies are referenced from `ReplicatedStorage` and the packages folder has to be named "Modules".
    - This only works because the module and its dependencies are all in the "shared" realm.

Moved `DialogConstants` and `DialogTypes` to be under `DialogInfo`.
- `DialogInfo` is synced to both the `DialogSystem` module and the `DialogStorage` folder.

Dialog sequences modules now reference `DialogStorage/_DialogInfo` instead of the internal modules under `DialogSystem`.

Added MIT license files.

## [v0.0.5] Beloved remote migration + Dialog storage | 2026/05/04

Migrated remote event usages to [BelovedRemote](https://github.com/MarioChao/beloved-remote).

Created a storage folder `DialogStorage` under `ServerScriptService`.
- Stores dialog sequences modules for organization.

Added a template dialog sequences module.

## [v0.0.4] UI fading transition + Preload images | 2026/03/10 (2)

Added UI fading transitions using `UIUtil`:
- Screen UI fades in & out when dialog starts & closes.
- Next indicator fades in & out.
- Options fade in when created.
- Dialog text, next indicator, and options fade out when querying for the next sequence.
- Speaker name fades out when it changes.

Added image preloading that occurs as soon as a dialog entry is received.

Fixed instant fading when options are spammed.

## [v0.0.3] Next indicator + Sequence warning + CharSpeed parameter | 2026/03/10 (1)

Added a visual indicator for proceeding to the next dialog sequence.
- Appears as `>>` at the bottom-right corner.

Added an output warning when a dialog sequence is missing both `nextSequenceId` and `optionId_sequenceIds`.
- In such cases, the dialog sequence will act like a closing dialogue.

Added `charSpeed` parameter to `DialogEntry.textData` to control the text writing speed (default 48).

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
