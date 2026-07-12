# sing-and-guess (你唱我猜)

iOS party game where one player hums/sings a song and others guess the title.

## Tech Stack
- **Language:** Swift 5.9
- **Framework:** SwiftUI (iOS 17+)
- **Build:** XcodeGen
- **Architecture:** MVVM

## Getting Started
```bash
make generate   # Generate Xcode project from project.yml
make open       # Open in Xcode
make build      # Build for simulator
```

## Gameplay
1. Add players (2+), configure rounds
2. Each round, a singer sees a song and hums/sings it (no lyrics!)
3. Others guess the song title
4. Score points for quick correct guesses
5. 50+ songs across 6 genres

## Scripts
- `make generate` — Generate Xcode project
- `make build` — Build for iOS simulator
- `make test` — Run XCTest tests
- `make clean` — Clean build artifacts

## Project Structure
```
├── SingAndGuess/
│   ├── SingAndGuessApp.swift    # App entry + phase routing
│   ├── Models/                  # Song, Player, GameState, etc.
│   ├── ViewModels/
│   │   └── GameViewModel.swift  # Game orchestrator
│   ├── Views/                   # 7 SwiftUI views
│   └── Data/                    # SongLibrary + songs.json
├── project.yml                  # XcodeGen spec
├── Makefile
└── AGENTS.md
```
