import Foundation
import Combine
import SwiftUI

/// Central game orchestrator — owns all game state and transitions
@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Published State

    @Published var phase: GamePhase = .setup
    @Published var players: [Player] = []
    @Published var teams: [Team] = []
    @Published var settings = GameSettings()

    // Current round
    @Published var currentRound: Int = 0
    @Published var currentSingerIndex: Int = 0
    @Published var currentSong: Song?

    // Timer
    @Published var remainingTime: TimeInterval = 30
    @Published var timerProgress: Double = 1.0
    @Published var isTimerRunning: Bool = false

    // Hints
    @Published var currentHintIndex: Int = 0
    @Published var revealedHints: [String] = []
    @Published var hintsAvailable: Bool = false

    // Guessing
    @Published var guessText: String = ""
    @Published var guessResult: GuessResult = .pending
    @Published var submittedGuesses: [UUID: String] = [:]  // playerID → guess

    // Scoring
    @Published var roundResults: [RoundResult] = []
    @Published var lastRoundResult: RoundResult?

    // Song pool management
    @Published var usedSongIDs: Set<String> = []

    // MARK: - Dependencies

    private let songLibrary = SongLibrary()
    private var timerCancellable: AnyCancellable?
    private var roundStartTime: Date?

    // MARK: - Computed

    var totalRounds: Int { settings.totalRounds }

    var currentSinger: Player? {
        guard !players.isEmpty,
              currentSingerIndex >= 0,
              currentSingerIndex < players.count else { return nil }
        return players[currentSingerIndex]
    }

    var guessers: [Player] {
        guard let singer = currentSinger else { return players }
        return players.filter { $0.id != singer.id }
    }

    var sortedPlayersByScore: [Player] {
        players.sorted { $0.score > $1.score }
    }

    var isLastRound: Bool {
        currentRound >= totalRounds
    }

    // MARK: - Player Management

    func addPlayer(name: String, avatar: String? = nil) {
        let av = avatar ?? Player.defaultAvatars.randomElement() ?? "😊"
        let player = Player(name: name, avatar: av)
        players.append(player)
    }

    func removePlayer(id: UUID) {
        players.removeAll { $0.id == id }
    }

    func updatePlayerName(id: UUID, name: String) {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].name = name
        }
    }

    var canStartGame: Bool {
        players.count >= 2
    }

    // MARK: - Game Lifecycle

    func startGame() {
        guard canStartGame else { return }

        currentRound = 0
        currentSingerIndex = 0
        usedSongIDs.removeAll()
        roundResults.removeAll()

        // Reset all player scores
        for i in players.indices {
            players[i].score = 0
            players[i].correctGuesses = 0
            players[i].successfulSings = 0
        }

        beginNextRound()
    }

    func beginNextRound() {
        guard currentRound < totalRounds else {
            phase = .results
            return
        }

        currentRound += 1
        guessText = ""
        guessResult = .pending
        submittedGuesses.removeAll()
        revealedHints.removeAll()
        currentHintIndex = 0
        lastRoundResult = nil

        // Pick a song
        pickSong()
        phase = .songReveal
    }

    private func pickSong() {
        currentSong = songLibrary.randomSong(
            genres: settings.selectedGenres,
            difficulties: settings.difficulties,
            exclude: usedSongIDs
        )

        // If pool exhausted, reset used songs
        if currentSong == nil {
            usedSongIDs.removeAll()
            currentSong = songLibrary.randomSong(
                genres: settings.selectedGenres,
                difficulties: settings.difficulties
            )
        }

        if let song = currentSong {
            usedSongIDs.insert(song.id)
        }
    }

    // MARK: - Singing Phase

    func startSinging() {
        phase = .singing
        remainingTime = settings.roundDuration
        timerProgress = 1.0
        isTimerRunning = true
        hintsAvailable = true
        revealedHints.removeAll()
        currentHintIndex = 0
        roundStartTime = Date()

        startTimer(duration: settings.roundDuration) { [weak self] in
            self?.onTimerExpired()
        }
    }

    func revealNextHint() {
        guard let song = currentSong,
              currentHintIndex < song.hints.count,
              currentHintIndex < settings.maxHints else { return }

        let hint = song.hints[currentHintIndex]
        revealedHints.append(hint)
        currentHintIndex += 1

        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func passSong() {
        stopTimer()
        isTimerRunning = false

        let elapsed = Date().timeIntervalSince(roundStartTime ?? Date())

        let result = RoundResult(
            id: UUID(),
            roundNumber: currentRound,
            singer: currentSinger ?? Player(name: "Unknown"),
            song: currentSong ?? Song(id: "?", title: "?", artist: "?", genre: .mandopop, difficulty: .easy, hints: []),
            guesser: nil,
            guessText: nil,
            timeSpent: elapsed,
            isCorrect: false,
            hintsUsed: currentHintIndex
        )

        roundResults.append(result)
        lastRoundResult = result

        phase = .scoring
        advanceSinger()
    }

    private func onTimerExpired() {
        isTimerRunning = false

        // Move to guessing phase
        phase = .guessing
        remainingTime = settings.guessDuration
        timerProgress = 1.0

        startTimer(duration: settings.guessDuration) { [weak self] in
            self?.onGuessTimerExpired()
        }
    }

    // MARK: - Guessing Phase

    func submitGuess(playerID: UUID, text: String) {
        guard phase == .guessing || phase == .singing else { return }

        submittedGuesses[playerID] = text

        // Check if correct
        if checkGuess(text) {
            onCorrectGuess(guesserID: playerID, text: text)
        }
    }

    private func checkGuess(_ guess: String) -> Bool {
        guard let song = currentSong else { return false }

        let normalizedGuess = guess
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")

        let normalizedTitle = song.title
            .lowercased()
            .replacingOccurrences(of: " ", with: "")

        return normalizedGuess.contains(normalizedTitle) || normalizedTitle.contains(normalizedGuess)
    }

    private func onCorrectGuess(guesserID: UUID, text: String) {
        stopTimer()
        isTimerRunning = false

        let elapsed = Date().timeIntervalSince(roundStartTime ?? Date())

        guard let guesser = players.first(where: { $0.id == guesserID }),
              let singer = currentSinger else { return }

        let result = RoundResult(
            id: UUID(),
            roundNumber: currentRound,
            singer: singer,
            song: currentSong ?? Song(id: "?", title: "?", artist: "?", genre: .mandopop, difficulty: .easy, hints: []),
            guesser: guesser,
            guessText: text,
            timeSpent: elapsed,
            isCorrect: true,
            hintsUsed: currentHintIndex
        )

        roundResults.append(result)
        lastRoundResult = result

        // Update scores
        awardPoints(result: result)

        // Haptic
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        phase = .scoring
        advanceSinger()
    }

    private func onGuessTimerExpired() {
        isTimerRunning = false

        let elapsed = Date().timeIntervalSince(roundStartTime ?? Date())

        let result = RoundResult(
            id: UUID(),
            roundNumber: currentRound,
            singer: currentSinger ?? Player(name: "Unknown"),
            song: currentSong ?? Song(id: "?", title: "?", artist: "?", genre: .mandopop, difficulty: .easy, hints: []),
            guesser: nil,
            guessText: nil,
            timeSpent: elapsed,
            isCorrect: false,
            hintsUsed: currentHintIndex
        )

        roundResults.append(result)
        lastRoundResult = result

        phase = .scoring
        advanceSinger()
    }

    // MARK: - Scoring

    private func awardPoints(result: RoundResult) {
        // Award singer
        if let singerIndex = players.firstIndex(where: { $0.id == result.singer.id }) {
            players[singerIndex].score += result.singerPoints
            if result.isCorrect {
                players[singerIndex].successfulSings += 1
            }
        }

        // Award guesser
        if let guesser = result.guesser,
           let guesserIndex = players.firstIndex(where: { $0.id == guesser.id }) {
            players[guesserIndex].score += result.guesserPoints
            players[guesserIndex].correctGuesses += 1
        }
    }

    func confirmScoring() {
        if currentRound >= totalRounds {
            phase = .results
        } else {
            beginNextRound()
        }
    }

    private func advanceSinger() {
        currentSingerIndex = (currentSingerIndex + 1) % players.count
    }

    // MARK: - Timer

    private func startTimer(duration: TimeInterval, onExpire: @escaping () -> Void) {
        timerCancellable?.cancel()

        let startDate = Date()
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let elapsed = Date().timeIntervalSince(startDate)
                let remaining = max(0, duration - elapsed)

                self.remainingTime = remaining
                self.timerProgress = remaining / duration

                if remaining <= 0 {
                    self.timerCancellable?.cancel()
                    onExpire()
                }
            }
    }

    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        isTimerRunning = false
    }

    // MARK: - Reset

    func resetGame() {
        stopTimer()
        phase = .setup
        players.removeAll()
        currentRound = 0
        currentSingerIndex = 0
        currentSong = nil
        roundResults.removeAll()
        revealedHints.removeAll()
        guessText = ""
        guessResult = .pending
        usedSongIDs.removeAll()
        settings = GameSettings()
    }
}

// MARK: - Guess Result Enum

enum GuessResult {
    case pending
    case correct(guesser: Player, points: Int)
    case wrong
    case timeout
}
