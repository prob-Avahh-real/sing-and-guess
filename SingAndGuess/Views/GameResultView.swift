import SwiftUI

/// Final results — game over screen with rankings and confetti
struct GameResultView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showConfetti: Bool = false
    @State private var showRanking: Bool = false
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        ZStack {
            Color(hex: "#1A1A2E").ignoresSafeArea()

            // Confetti overlay
            confettiLayer

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    // Trophy header
                    trophyHeader

                    // Podium (top 3)
                    podiumView

                    // Full rankings
                    fullRankings

                    // Game stats
                    gameStats

                    // Action buttons
                    actionButtons
                        .padding(.top, 8)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                showRanking = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                showConfetti = true
            }
            generateConfetti()
        }
    }

    // MARK: - Confetti

    private func generateConfetti() {
        let colors: [Color] = [
            Color(hex: "#FF6B6B"), Color(hex: "#FFD93D"), Color(hex: "#6BCB77"),
            Color(hex: "#4D96FF"), Color(hex: "#9B59B6"), Color(hex: "#FF8C42")
        ]
        let shapes: [String] = ["●", "■", "▲", "★", "♦"]

        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: UUID(),
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: -0.3...0),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2),
                color: colors.randomElement()!,
                symbol: shapes.randomElement()!,
                delay: Double.random(in: 0...1.5),
                duration: Double.random(in: 2...4)
            )
            confettiPieces.append(piece)
        }
    }

    private var confettiLayer: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Text(piece.symbol)
                    .font(.system(size: 14 * piece.scale))
                    .foregroundColor(piece.color)
                    .position(
                        x: piece.x * UIScreen.main.bounds.width,
                        y: showConfetti
                            ? (1.2 * UIScreen.main.bounds.height)
                            : (piece.y * UIScreen.main.bounds.height)
                    )
                    .rotationEffect(.degrees(showConfetti ? piece.rotation + 360 : piece.rotation))
                    .opacity(showConfetti ? 0 : 1)
                    .animation(
                        .linear(duration: piece.duration).delay(piece.delay),
                        value: showConfetti
                    )
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Trophy Header

    private var trophyHeader: some View {
        VStack(spacing: 8) {
            Text("🏆")
                .font(.system(size: 64))
                .scaleEffect(showRanking ? 1.0 : 0.3)
                .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3), value: showRanking)

            Text("游戏结束！")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            if let winner = viewModel.sortedPlayersByScore.first {
                Text("\(winner.avatar) \(winner.name) 获胜！")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#FFD93D"))
            }

            Text("共 \(viewModel.totalRounds) 回合 · \(viewModel.players.count) 位玩家")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Podium

    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // 2nd place
            if viewModel.sortedPlayersByScore.count >= 2 {
                podiumPlayer(
                    player: viewModel.sortedPlayersByScore[1],
                    rank: 2,
                    height: 100,
                    color: Color(hex: "#C0C0C0")
                )
            }

            // 1st place
            if let first = viewModel.sortedPlayersByScore.first {
                podiumPlayer(
                    player: first,
                    rank: 1,
                    height: 140,
                    color: Color(hex: "#FFD93D")
                )
            }

            // 3rd place
            if viewModel.sortedPlayersByScore.count >= 3 {
                podiumPlayer(
                    player: viewModel.sortedPlayersByScore[2],
                    rank: 3,
                    height: 80,
                    color: Color(hex: "#CD7F32")
                )
            }
        }
        .frame(height: 160)
        .padding(.vertical, 16)
        .scaleEffect(showRanking ? 1.0 : 0.7)
        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.4), value: showRanking)
    }

    private func podiumPlayer(player: Player, rank: Int, height: CGFloat, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(player.avatar)
                .font(.system(size: 32))

            Text(player.name)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)

            Text("\(player.score)分")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.15))
        )
        .overlay(
            VStack {
                Spacer()
                Text(rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉")
                    .font(.system(size: 20))
                    .offset(y: 14)
            }
        )
    }

    // MARK: - Full Rankings

    private var fullRankings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 完整排名")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                ForEach(Array(viewModel.sortedPlayersByScore.enumerated()), id: \.element.id) { index, player in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(
                                index == 0 ? Color(hex: "#FFD93D") :
                                index == 1 ? Color(hex: "#C0C0C0") :
                                index == 2 ? Color(hex: "#CD7F32") :
                                .white.opacity(0.5)
                            )
                            .frame(width: 28)

                        Text(player.avatar)
                            .font(.system(size: 24))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            HStack(spacing: 8) {
                                Label("猜对\(player.correctGuesses)", systemImage: "checkmark")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "#6BCB77"))
                                Label("唱对\(player.successfulSings)", systemImage: "music.mic")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "#FF6B6B"))
                            }
                        }

                        Spacer()

                        Text("\(player.score)")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "#FFD93D"))

                        Text("分")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(14)
                    .background(
                        index == 0 ? Color(hex: "#FFD93D").opacity(0.08) : Color.white.opacity(0.03)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    // MARK: - Game Stats

    private var gameStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📈 游戏统计")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(
                    icon: "🎵",
                    value: "\(viewModel.roundResults.count)",
                    label: "总回合数"
                )

                statCard(
                    icon: "✅",
                    value: "\(viewModel.roundResults.filter(\.isCorrect).count)",
                    label: "猜对次数"
                )

                statCard(
                    icon: "💡",
                    value: "\(viewModel.roundResults.reduce(0) { $0 + $1.hintsUsed })",
                    label: "提示使用"
                )

                statCard(
                    icon: "⏱️",
                    value: String(format: "%.1fs", viewModel.roundResults.map(\.timeSpent).reduce(0, +)),
                    label: "总用时"
                )
            }
        }
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 24))
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    viewModel.resetGame()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("再来一局")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FF6B6B"), Color(hex: "#EE5A24")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color(hex: "#FF6B6B").opacity(0.3), radius: 10, y: 5)
            }

            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    viewModel.resetGame()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                    Text("返回首页")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical: 12)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

// MARK: - Confetti Model

struct ConfettiPiece: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let rotation: Double
    let scale: CGFloat
    let color: Color
    let symbol: String
    let delay: Double
    let duration: Double
}
