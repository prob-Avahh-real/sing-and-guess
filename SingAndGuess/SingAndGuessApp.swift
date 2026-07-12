import SwiftUI

@main
struct SingAndGuessApp: App {
    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            contentView
                .preferredColorScheme(.dark)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.phase {
        case .setup:
            GameSetupView()
                .environmentObject(viewModel)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))

        case .songReveal:
            SongRevealView()
                .environmentObject(viewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .singing:
            SingingView()
                .environmentObject(viewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .guessing:
            GuessInputView()
                .environmentObject(viewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .scoring:
            ScoreBoardView()
                .environmentObject(viewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .results:
            GameResultView()
                .environmentObject(viewModel)
                .transition(.opacity.combined(with: .scale(scale: 1.05)))

        default:
            HomeView()
                .environmentObject(viewModel)
        }
    }
}
