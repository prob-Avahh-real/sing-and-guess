import SwiftUI

/// Shows round result and current scoreboard between rounds
struct ScoreBoardView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showDetails: Bool = false
    @State private var animateScores: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "#1A1A2E").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Round result
                    roundResultCard

                    // Scoreboard
                    scoreboardSection

                    // Round history
                    roundHistorySection
                        .opacity(showDetails ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showDetails)

                    // Toggle history
                    Button {
                        withAnimation {
                            showDetails.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(showDetails ? "隐藏详情" : "查看详情")
                            Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    }

                    // Next button
                    nextButton
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    animateScores = true
                }
            }
        }
    }

    // MARK: - Round Result Card

    private var roundResultCard: some View {
        VStack(spacing: 16) {
            // Result emoji
            Text(viewModel.lastRoundResult?.isCorrect == true ? "🎉" : "😅")
                .font(.system(size: 56))
                .scaleEffect(animateScores ? 1.0 : 0.3)
                .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.2), value: animateScores)

            // Result text
            if let result = viewModel.lastRoundResult {
                Text(result.isCorrect ? "猜对了！" : "无人猜中")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(result.isCorrect ? Color(hex: "#6BCB77") : Color(hex: "#FF6B6B"))

                if result.isCorrect, let guesser = result.guesser {
                    Text("\(guesser.avatar) \(guesser.name) 猜出了这首歌！")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)

                    Text("答案是：\(result.song.title) - \(result.song.artist)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#FFD93D"))
                } else {
                    Text("答案是：\(result.song.title) - \(result.song.artist)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#FFD93D"))
                }

                // Points breakdown
                VStack(spacing: 6) {
                    if result.isCorrect {
                        HStack {
                            Text("🎤 \(result.singer.name)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text("+\(result.singerPoints) 分")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#6BCB77"))
                        }

                        if let guesser = result.guesser {
                            HStack {
                                Text("💡 \(guesser.name)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("+\(result.guesserPoints) 分")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#6BCB77"))
                            }
                        }
                    }

                    HStack {
                        Text("⏱️ 用时")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text(String(format: "%.1f 秒", result.timeSpent))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("💡 提示")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("\(result.hintsUsed) 个")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.03))
        )
    }

    // MARK: - Scoreboard

    private var scoreboardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏆 排名榜")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                ForEach(Array(viewModel.sortedPlayersByScore.enumerated()), id: \.element.id) { index, player in
                    HStack(spacing: 12) {
                        // Rank
                        rankBadge(index: index)

                        Text(player.avatar)
                            .font(.system(size: 28))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            Text("猜对 \(player.correctGuesses) · 唱对 \(player.successfulSings)")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                        }

                        Spacer()

                        Text("\(player.score)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "#FFD93D"))
                            .scaleEffect(animateScores ? 1.0 : 0.5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.3 + Double(index) * 0.1), value: animateScores)

                        Text("分")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(12)
                    .background(
                        index == 0 ? Color(hex: "#FFD93D").opacity(0.1) : Color.white.opacity(0.03)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private func rankBadge(index: Int) -> some View {
        Group {
            switch index {
            case 0:
                Text("🥇")
                    .font(.system(size: 24))
            case 1:
                Text("🥈")
                    .font(.system(size: 22))
            case 2:
                Text("🥉")
                    .font(.system(size: 20))
            default:
                Text("\(index + 1)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Round History

    private var roundHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 回合记录")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            ForEach(viewModel.roundResults.reversed()) { result in
                HStack(spacing: 12) {
                    Text("R\(result.roundNumber)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 30)

                    Text(result.isCorrect ? "✅" : "❌")
                        .font(.system(size: 14))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.song.title)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        Text(result.song.artist)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    Spacer()

                    if result.isCorrect, let guesser = result.guesser {
                        Text("\(guesser.name) +\(result.guesserPoints)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#6BCB77"))
                    }
                }
                .padding(10)
                .background(Color.white.opacity(0.02))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Next Button

    private var nextButton: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                viewModel.confirmScoring()
            }
        } label: {
            HStack(spacing: 8) {
                Text(viewModel.isLastRound ? "查看最终结果" : "下一回合")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#6BCB77"), Color(hex: "#4D96FF")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: "#6BCB77").opacity(0.3), radius: 10, y: 5)
        }
    }
}
