import SwiftUI

/// Game setup: add players, configure rounds, select genres
struct GameSetupView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var newPlayerName: String = ""
    @State private var showModePicker = false

    private let avatarGridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        ZStack {
            Color(hex: "#1A1A2E").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Game Mode
                    modeSection

                    // Players
                    playersSection

                    // Add Player
                    addPlayerSection

                    // Settings
                    settingsSection

                    // Start button
                    startButton

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("⚙️ 游戏设置")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("配置玩家和规则，准备开唱！")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.top, 16)
    }

    // MARK: - Mode

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("游戏模式")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 12) {
                ForEach(GameMode.allCases) { mode in
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            viewModel.settings.mode = mode
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(mode.icon)
                                .font(.system(size: 28))
                            Text(mode.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                            Text(mode.description)
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(viewModel.settings.mode == mode ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            viewModel.settings.mode == mode
                                ? Color(hex: "#FF6B6B").opacity(0.3)
                                : Color.white.opacity(0.05)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    viewModel.settings.mode == mode
                                        ? Color(hex: "#FF6B6B")
                                        : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
    }

    // MARK: - Players

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("玩家")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("\(viewModel.players.count)人")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#FFD93D"))
            }

            if viewModel.players.isEmpty {
                VStack(spacing: 8) {
                    Text("👥")
                        .font(.system(size: 36))
                    Text("至少添加 2 位玩家才能开始")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.players) { player in
                        playerRow(player)
                    }
                }
            }
        }
    }

    private func playerRow(_ player: Player) -> some View {
        HStack(spacing: 12) {
            Text(player.avatar)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("猜对 \(player.correctGuesses) 次 · 唱对 \(player.successfulSings) 次")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            Button {
                withAnimation {
                    viewModel.removePlayer(id: player.id)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "#FF6B6B").opacity(0.7))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Add Player

    private var addPlayerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField("输入玩家名字", text: $newPlayerName)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                Button {
                    addPlayerWithDefaultAvatar()
                } label: {
                    Text("添加")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.gray
                                : Color(hex: "#6BCB77")
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Avatar picker
            LazyVGrid(columns: avatarGridColumns, spacing: 8) {
                ForEach(Player.defaultAvatars, id: \.self) { avatar in
                    Button {
                        addPlayerWithAvatar(avatar)
                    } label: {
                        Text(avatar)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private func addPlayerWithDefaultAvatar() {
        let name = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        withAnimation {
            viewModel.addPlayer(name: name)
            newPlayerName = ""
        }
    }

    private func addPlayerWithAvatar(_ avatar: String) {
        let name = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        withAnimation {
            viewModel.addPlayer(name: name, avatar: avatar)
            newPlayerName = ""
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("游戏参数")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            // Rounds
            settingStepper(
                icon: "🔄",
                title: "回合数",
                value: $viewModel.settings.totalRounds,
                range: viewModel.settings.roundsRange
            )

            // Duration
            settingStepper(
                icon: "⏱️",
                title: "演唱时间",
                value: Binding(
                    get: { Int(viewModel.settings.roundDuration) },
                    set: { viewModel.settings.roundDuration = TimeInterval($0) }
                ),
                range: 15...90,
                suffix: "秒"
            )

            // Max hints
            settingStepper(
                icon: "💡",
                title: "提示次数",
                value: $viewModel.settings.maxHints,
                range: 1...4,
                suffix: "次"
            )

            // Genre picker
            genrePickerSection
        }
    }

    private func settingStepper(
        icon: String,
        title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        suffix: String = ""
    ) -> some View {
        HStack {
            Text(icon)
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    if value.wrappedValue > range.lowerBound {
                        value.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#FF6B6B"))
                }

                Text("\(value.wrappedValue)\(suffix)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "#FFD93D"))
                    .frame(minWidth: 40)

                Button {
                    if value.wrappedValue < range.upperBound {
                        value.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#6BCB77"))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var genrePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🎵")
                Text("歌曲类别")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }

            FlowLayout(spacing: 8) {
                ForEach(SongGenre.allCases) { genre in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            if viewModel.settings.selectedGenres.contains(genre) {
                                viewModel.settings.selectedGenres.remove(genre)
                            } else {
                                viewModel.settings.selectedGenres.insert(genre)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(genre.icon)
                            Text(genre.rawValue)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(viewModel.settings.selectedGenres.contains(genre) ? .white : .white.opacity(0.4))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.settings.selectedGenres.contains(genre)
                                ? Color(hex: genre.colorHex).opacity(0.3)
                                : Color.white.opacity(0.05)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    viewModel.settings.selectedGenres.contains(genre)
                                        ? Color(hex: genre.colorHex)
                                        : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                viewModel.startGame()
            }
        } label: {
            HStack(spacing: 10) {
                Text("🎤")
                Text("开始游戏")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                viewModel.canStartGame
                    ? LinearGradient(
                        colors: [Color(hex: "#FF6B6B"), Color(hex: "#EE5A24")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: viewModel.canStartGame
                    ? Color(hex: "#FF6B6B").opacity(0.4)
                    : Color.clear,
                radius: 12,
                y: 6
            )
        }
        .disabled(!viewModel.canStartGame)
        .padding(.top, 8)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > (proposal.width ?? .infinity) {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            totalWidth = max(totalWidth, lineWidth)
        }

        totalHeight += lineHeight
        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]

            if lineX + size.width > bounds.maxX {
                lineY += lineHeight + spacing
                lineHeight = 0
                lineX = bounds.minX
            }

            subview.place(
                at: CGPoint(x: lineX, y: lineY),
                proposal: .unspecified
            )

            lineHeight = max(lineHeight, size.height)
            lineX += size.width + spacing
        }
    }
}
