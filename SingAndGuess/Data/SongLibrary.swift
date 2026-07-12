import Foundation

/// Loads and manages the song library with filtering support
final class SongLibrary: ObservableObject {

    @Published private(set) var allSongs: [Song] = []

    init() {
        loadSongs()
    }

    // MARK: - Loading

    private func loadSongs() {
        guard let url = Bundle.main.url(forResource: "songs", withExtension: "json") else {
            print("⚠️ SongLibrary: songs.json not found in bundle")
            allSongs = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            allSongs = try decoder.decode([Song].self, from: data)
            print("✅ SongLibrary: loaded \(allSongs.count) songs")
        } catch {
            print("❌ SongLibrary: failed to decode songs.json — \(error.localizedDescription)")
            allSongs = []
        }
    }

    // MARK: - Filtering

    func filteredSongs(
        genres: Set<SongGenre> = Set(SongGenre.allCases),
        difficulties: Set<Difficulty> = Set(Difficulty.allCases)
    ) -> [Song] {
        allSongs.filter { genres.contains($0.genre) && difficulties.contains($0.difficulty) }
    }

    func randomSong(
        genres: Set<SongGenre> = Set(SongGenre.allCases),
        difficulties: Set<Difficulty> = Set(Difficulty.allCases),
        exclude: Set<String> = []
    ) -> Song? {
        let pool = filteredSongs(genres: genres, difficulties: difficulties)
            .filter { !exclude.contains($0.id) }
        return pool.randomElement()
    }

    func songsByGenre(_ genre: SongGenre) -> [Song] {
        allSongs.filter { $0.genre == genre }
    }

    var genreCounts: [(SongGenre, Int)] {
        SongGenre.allCases.map { genre in
            (genre, allSongs.filter { $0.genre == genre }.count)
        }
    }

    var songCount: Int { allSongs.count }
}
