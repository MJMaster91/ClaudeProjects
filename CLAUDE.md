# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a single-file browser game — `hangman.html` contains all HTML, CSS, and JavaScript in one self-contained file. There is no build step, no bundler, no dependencies, and no server. Open the file directly in a browser to run it.

## Architecture

Everything lives in `hangman.html` in three sections:

- **`<style>`** — Dark-themed UI (palette: `#1a1a2e` background, `#e94560` red, `#64ffda` teal, `#a8b2d8` muted blue). Key selectors: `.letter-slot`, `.key`, `#status`, `#gallows`.
- **`<svg id="gallows">`** — The hangman figure is drawn in SVG. Each of the 6 body parts (`h-head`, `h-body`, `h-larm`, `h-rarm`, `h-lleg`, `h-rleg`) is a `<g>` element with `display:none` toggled by JS. Win/lose overlays (`h-win-smile`, `h-eyes-x`) are nested inside `h-head`.
- **`<script>`** — Pure vanilla JS. Core state: `word` (string), `guessed` (Set), `wrong` (0–6 count), `gameOver` (bool). Key functions: `startGame()`, `guess(letter)`, `renderWord()`, `renderKeyboard()`, `checkWin()`, `endGame(won)`.

## Word List

`WORDS` array at the top of the `<script>` block — each entry is `{ word, hint }`. All words are lowercase; guesses are compared as lowercase. To add words, append to that array.

## Git Workflow

Commit and push after every meaningful change:

```powershell
git add hangman.html
git commit -m "short description of what changed"
git push
```

Remote: `https://github.com/MJMaster91/ClaudeProjects`
