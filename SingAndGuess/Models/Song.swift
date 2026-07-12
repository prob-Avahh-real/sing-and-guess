import Foundation

// MARK: - Song Model

struct Song: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let genre: SongGenre
    let difficulty: Difficulty
    let hints: [String]      // progressive hints: artist → genre clue → first letter → lyric snippet

    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Genre

enum SongGenre: String, Codable, CaseIterable, Identifiable {
    case mandopop  = "华语流行"
    case cantopop  = "粤语经典"
    case english   = "英文金曲"
    case folk      = "民谣"
    case rock      = "摇滚"
    case film      = "影视金曲"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .mandopop:  return "🎵"
        case .cantopop:  return "🎤"
        case .english:   return "🎸"
        case .folk:      return "🪕"
        case .rock:      return "🤘"
        case .film:      return "🎬"
        }
    }

    var colorHex: String {
        switch self {
        case .mandopop:  return "#FF6B6B"
        case .cantopop:  return "#FFD93D"
        case .english:   return "#6BCB77"
        case .folk:      return "#4D96FF"
        case .rock:      return "#9B59B6"
        case .film:      return "#FF8C42"
        }
    }
}

// MARK: - Difficulty

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case easy   = "简单"
    case medium = "中等"
    case hard   = "困难"

    var id: String { rawValue }

    var stars: String {
        switch self {
        case .easy:   return "⭐"
        case .medium: return "⭐⭐"
        case .hard:   return "⭐⭐⭐"
        }
    }
}
