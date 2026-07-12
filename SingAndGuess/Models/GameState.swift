import Foundation

// MARK: - Game Phase

enum GamePhase: Equatable {
    case setup
    case songReveal
    case singing
    case guessing
    case scoring
    case results
}

// MARK: - Game Mode

enum GameMode: String, CaseIterable, Identifiable {
    case individual = "个人战"
    case team       = "团队战"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .individual: return "👤"
        case .team:       return "👥"
        }
    }

    var description: String {
        switch self {
        case .individual: return "每人轮流当歌手"
        case .team:       return "组队对抗，轮流演唱"
        }
    }
}

// MARK: - Round Result

struct RoundResult: Identifiable {
    let id: UUID
    let roundNumber: Int
    let singer: Player
    let song: Song
    let guesser: Player?          // who guessed correctly (nil if passed)
    let guessText: String?
    let timeSpent: TimeInterval   // seconds elapsed before correct guess
    let isCorrect: Bool
    let hintsUsed: Int

    var singerPoints: Int {
        isCorrect ? max(10, 100 - Int(timeSpent) * 2) : 0
    }

    var guesserPoints: Int {
        guard isCorrect, let _ = guesser else { return 0 }
        return max(20, 200 - Int(timeSpent) * 4)
    }
}

// MARK: - Game Settings

struct GameSettings {
    var mode: GameMode = .individual
    var totalRounds: Int = 5
    var roundDuration: TimeInterval = 30      // seconds for singer to perform
    var guessDuration: TimeInterval = 15       // seconds for guessers to submit
    var maxHints: Int = 3                      // progressive hints available
    var selectedGenres: Set<SongGenre> = Set(SongGenre.allCases)
    var difficulties: Set<Difficulty> = Set(Difficulty.allCases)
    var showLyricsHint: Bool = true

    var roundsRange: ClosedRange<Int> { 3...20 }
    var durationRange: ClosedRange<Double> { 15...90 }
}
