import SwiftUI

/// Singing phase — singer performs with timer, hints, and pass option
struct SingingView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color(hex: "#1A1A2E").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top info bar
                topBar

                Spacer()

                // Timer ring
                timerRing
                    .padding(.vertical, 20)

                // Hints
                hintsSection

                Spacer()

                // Action buttons
                actionButtons
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("🎤 演唱中")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))

                if let singer = viewModel.currentSinger {
                    Text("\(singer.avatar) \(singer.name)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            // Time display
            Text(timeString(from: viewModel.remainingTime))
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .foregroundColor(viewModel.remainingTime <= 10 ? Color(hex: "#FF6B6B") : Color(hex: "#FFD93D"))
                .scaleEffect(viewModel.remainingTime <= 10 ? pulseScale : 1.0)
                .animation(
                    viewModel.remainingTime <= 10
                        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .default,
                    value: pulseScale
                )
        }
        .padding(.top, 16)
        .onChange(of: viewModel.remainingTime) { _, newValue in
            if newValue <= 10 {
                pulseScale = 1.15
            } else {
                pulseScale = 1.0
            }
        }
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 12)
                .frame(width: 200, height: 200)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.timerProgress))
                .stroke(
                    timerGradient,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: viewModel.timerProgress)

            // Center display
            VStack(spacing: 4) {
                Text("🎵")
                    .font(.system(size: 40))
                Text("哼唱中...")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private var timerGradient: AngularGradient {
        if viewModel.remainingTime <= 10 {
            AngularGradient(
                colors: [Color(hex: "#FF6B6B"), Color(hex: "#EE5A24")],
                center: .center
            )
        } else {
            AngularGradient(
                colors: [Color(hex: "#6BCB77"), Color(hex: "#4D96FF"), Color(hex: "#FFD93D")],
                center: .center
            )
        }
    }

    // MARK: - Hints

    private var hintsSection: some View {
        VStack(spacing: 12) {
            // Hint button
            Button {
                viewModel.revealNextHint()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                    Text("显示提示 (\(viewModel.currentHintIndex + 1)/\(viewModel.settings.maxHints))")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundColor(
                    viewModel.currentHintIndex < viewModel.settings.maxHints
                        ? Color(hex: "#FFD93D")
                        : Color.gray
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    viewModel.currentHintIndex < viewModel.settings.maxHints
                        ? Color(hex: "#FFD93D").opacity(0.15)
                        : Color.white.opacity(0.05)
                )
                .clipShape(Capsule())
            }
            .disabled(viewModel.currentHintIndex >= viewModel.settings.maxHints)

            // Revealed hints
            if !viewModel.revealedHints.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.revealedHints.enumerated()), id: \.offset) { index, hint in
                        HStack(spacing: 10) {
                            Text("💡")
                                .font(.system(size: 14))
                            Text(hint)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color(hex: "#FFD93D").opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4), value: viewModel.revealedHints.count)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Pass button
            Button {
                viewModel.passSong()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "forward.end.fill")
                    Text("跳过")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            // If someone guesses during singing, show hint
            if !viewModel.submittedGuesses.isEmpty {
                Text("有人猜对了！等待判定...")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#6BCB77"))
            }
        }
    }

    // MARK: - Helpers

    private func timeString(from interval: TimeInterval) -> String {
        let seconds = Int(interval)
        let tenths = Int((interval - Double(seconds)) * 10)
        return String(format: "%02d.%01d", seconds, abs(tenths))
    }
}
