import SwiftUI

/// Private screen shown to the singer — reveals the song they need to perform
struct SongRevealView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var isRevealed: Bool = false
    @State private var cardRotation: Double = 0

    var body: some View {
        ZStack {
            Color(hex: "#1A1A2E").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                Spacer()

                // Song card
                songCard

                Spacer()

                // Action button
                actionButton
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
                isRevealed = true
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("第 \(viewModel.currentRound) / \(viewModel.totalRounds) 回合")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))

                if let singer = viewModel.currentSinger {
                    HStack(spacing: 6) {
                        Text(singer.avatar)
                        Text("\(singer.name) 是歌手")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }

            Spacer()
        }
        .padding(.top, 16)
    }

    // MARK: - Song Card

    private var songCard: some View {
        VStack(spacing: 0) {
            // "Tap to reveal" or revealed content
            if !isRevealed {
                VStack(spacing: 16) {
                    Text("🤫")
                        .font(.system(size: 64))
                    Text("点击卡片查看歌曲")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#FF6B6B"), Color(hex: "#FFD93D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        isRevealed = true
                    }
                }
            } else {
                revealedCard
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var revealedCard: some View {
        VStack(spacing: 24) {
            // Genre badge
            HStack(spacing: 8) {
                Text(viewModel.currentSong?.genre.icon ?? "🎵")
                    .font(.system(size: 16))
                Text(viewModel.currentSong?.genre.rawValue ?? "")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(viewModel.currentSong?.difficulty.stars ?? "")
            }
            .padding(.horizontal, 4)

            // Song title
            Text(viewModel.currentSong?.title ?? "???")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Artist
            Text(viewModel.currentSong?.artist ?? "")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#FFD93D"))

            Divider()
                .background(Color.white.opacity(0.15))

            // Hint preview
            VStack(alignment: .leading, spacing: 4) {
                Text("💡 可用提示")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                Text("歌手名 → 曲风提示 → 首字母 → 歌词片段")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }

            // Reminder
            Text("⚠️ 记住后开始哼唱，不能说歌词或歌名！")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#FF6B6B"))
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#16213E"), Color(hex: "#0F3460")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#FF6B6B"), Color(hex: "#FFD93D")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color(hex: "#FF6B6B").opacity(0.2), radius: 20, y: 10)
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                viewModel.startSinging()
            }
        } label: {
            HStack(spacing: 10) {
                Text("🎤")
                    .font(.system(size: 24))
                Text("准备好了，开始表演！")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#FF6B6B"), Color(hex: "#EE5A24")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(hex: "#FF6B6B").opacity(0.4), radius: 12, y: 6)
        }
    }
}
