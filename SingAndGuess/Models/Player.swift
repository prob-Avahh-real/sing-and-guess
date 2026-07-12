import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var score: Int
    var avatar: String           // emoji avatar
    var correctGuesses: Int      // times this player guessed correctly
    var successfulSings: Int     // times someone guessed their song

    init(name: String, avatar: String = "😊") {
        self.id = UUID()
        self.name = name
        self.avatar = avatar
        self.score = 0
        self.correctGuesses = 0
        self.successfulSings = 0
    }

    static let defaultAvatars = [
        "😊", "😎", "🤩", "🥳", "😇", "🤓", "🦊", "🐱",
        "🐶", "🐼", "🦄", "🐸", "🎤", "🎸", "🎹", "🥁"
    ]

    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Team support

struct Team: Identifiable, Codable {
    let id: UUID
    var name: String
    var members: [Player]
    var icon: String

    var score: Int {
        members.reduce(0) { $0 + $1.score }
    }

    init(name: String, members: [Player], icon: String = "👥") {
        self.id = UUID()
        self.name = name
        self.members = members
        self.icon = icon
    }
}
