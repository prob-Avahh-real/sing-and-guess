import SwiftUI

/// Home / landing screen
struct HomeView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showRules = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#1A1A2E"), Color(hex: "#16213E"), Color(hex: "#0F3460")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("🎤")
                        .font(.system(size: 64))

                    Text("你唱我猜")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text("Sing & Guess")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#FF6B6B"))
                }

                Spacer().frame(height: 48)

                // Start button
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        viewModel.phase = .setup
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text("开始游戏")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Image(systemName: "play.fill")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
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

                Spacer().frame(height: 20)

                // Rules button
                Button {
                    showRules = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle")
                        Text("游戏规则")
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#FFD93D"))
                }

                Spacer().frame(height: 40)

                // Feature cards
                HStack(spacing: 16) {
                    featureCard(icon: "🎵", title: "50+ 歌曲", subtitle: "中英文经典")
                    featureCard(icon: "⏱️", title: "限时挑战", subtitle: "紧张刺激")
                    featureCard(icon: "🏆", title: "积分排行", subtitle: "争夺冠军")
                }
                .padding(.horizontal, 24)

                Spacer()
                Spacer()
            }
        }
        .sheet(isPresented: $showRules) {
            RulesView()
        }
    }

    private func featureCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Rules Sheet

struct RulesView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    RuleSection(
                        number: "1",
                        title: "抽选歌曲",
                        description: "系统随机为歌手分配一首歌曲，只有歌手可以看到歌名。"
                    )
                    RuleSection(
                        number: "2",
                        title: "哼唱表演",
                        description: "歌手用哼唱、口哨、啦啦啦等方式演绎旋律，不能说歌词或歌名！计时器开始倒数。"
                    )
                    RuleSection(
                        number: "3",
                        title: "使用提示",
                        description: "歌手可以请求提示（按从难到易：歌手名 → 曲风 → 首字母 → 歌词片段），但猜中得分会降低。"
                    )
                    RuleSection(
                        number: "4",
                        title: "抢答猜歌",
                        description: "其他玩家输入歌名进行猜测。猜对越快分数越高。"
                    )
                    RuleSection(
                        number: "5",
                        title: "计分规则",
                        description: "歌手得分 = 100 - 用时×2（有人猜对才得分）\n猜者得分 = 200 - 用时×4\n无人猜对则双方均不得分。"
                    )

                    VStack(spacing: 12) {
                        HStack {
                            Text("⚠️ 重要规则")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            bulletItem("歌手不能说出歌名或歌词中的任何字")
                            bulletItem("只能用哼唱、啦啦啦、口哨等方式")
                            bulletItem("可以用手势或动作辅助")
                            bulletItem("超时后进入抢答阶段（15秒）")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
            .navigationTitle("游戏规则")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("知道了") { dismiss() }
                }
            }
        }
    }

    private func bulletItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.orange)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct RuleSection: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color(hex: "#FF6B6B"))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Color Hex Helper

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
