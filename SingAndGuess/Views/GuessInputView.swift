import SwiftUI

/// Guessing phase — guessers submit their answers
struct GuessInputView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var localGuess: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color(hex: "#1A1A2E").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                Spacer()

                // Timer + prompt
                timerSection

                Spacer().frame(height: 24)

                // Song hints visible to guessers
                hintDisplay

                Spacer()

                // Input area
                inputSection
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .onAppear {
                isFocused = true
                localGuess = ""
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("✍️ 猜歌时间")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))

                if let singer = viewModel.currentSinger {
                    Text("\(singer.avatar) \(singer.name) 刚刚演唱了...")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            Text(timeString(from: viewModel.remainingTime))
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .foregroundColor(viewModel.remainingTime <= 5 ? Color(hex: "#FF6B6B") : Color(hex: "#FFD93D"))
        }
        .padding(.top, 16)
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        VStack(spacing: 16) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#FF6B6B"), Color(hex: "#FFD93D")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(viewModel.timerProgress), height: 8)
                        .animation(.linear(duration: 0.1), value: viewModel.timerProgress)
                }
            }
            .frame(height: 8)

            Text("猜出歌手哼的歌曲是什么？")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Hint Display

    private var hintDisplay: some View {
        VStack(spacing: 8) {
            if !viewModel.revealedHints.isEmpty {
                ForEach(Array(viewModel.revealedHints.enumerated()), id: \.offset) { index, hint in
                    HStack(spacing: 10) {
                        Text("💡")
                        Text(hint)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(hex: "#FFD93D").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: 12) {
            // Text field
            HStack(spacing: 12) {
                TextField("输入歌名...", text: $localGuess)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        submitGuess()
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#FF6B6B").opacity(0.3), lineWidth: 1)
                    )

                Button {
                    submitGuess()
                } label: {
                    Text("猜测")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            localGuess.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.gray.opacity(0.5)
                                : Color(hex: "#6BCB77")
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(localGuess.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Who's guessing
            if viewModel.settings.mode == .individual {
                guesserButtons
            } else {
                // Team mode — each player submits individually
                guesserButtons
            }
        }
    }

    private var guesserButtons: some View {
        VStack(spacing: 8) {
            Text("谁猜的？")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: min(4, viewModel.guessers.count)),
                spacing: 8
            ) {
                ForEach(viewModel.guessers) { guesser in
                    Button {
                        localGuess = ""
                        viewModel.submitGuess(playerID: guesser.id, text: localGuess.isEmpty ? "" : localGuess)
                    } label: {
                        HStack(spacing: 6) {
                            Text(guesser.avatar)
                                .font(.system(size: 16))
                            Text(guesser.name)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.submittedGuesses[guesser.id] != nil
                                ? Color(hex: "#6BCB77").opacity(0.3)
                                : Color.white.opacity(0.08)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    viewModel.submittedGuesses[guesser.id] != nil
                                        ? Color(hex: "#6BCB77")
                                        : Color.clear,
                                    lineWidth: 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.submittedGuesses[guesser.id] != nil)
                }
            }
        }
    }

    // MARK: - Actions

    private func submitGuess() {
        let text = localGuess.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        // For simplicity, use first guesser who hasn't submitted
        if let firstGuesser = viewModel.guessers.first(where: { viewModel.submittedGuesses[$0.id] == nil }) {
            viewModel.submitGuess(playerID: firstGuesser.id, text: text)
            localGuess = ""
        }
    }

    private func timeString(from interval: TimeInterval) -> String {
        let seconds = Int(interval)
        return String(format: "%02d", max(0, seconds))
    }
}
