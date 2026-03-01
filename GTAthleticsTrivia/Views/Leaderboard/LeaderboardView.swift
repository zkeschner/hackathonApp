import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var users: [AppUser] = []

    var sortedUsers: [AppUser] {
        users.sorted { $0.points > $1.points }
    }

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Subtitle
                    Text("Top Yellow Jackets")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.top, 8)

                    // Podium (Top 3)
                    if sortedUsers.count >= 3 {
                        podiumView
                    }

                    // Full Rankings
                    VStack(spacing: 8) {
                        ForEach(Array(sortedUsers.enumerated()), id: \.element.id) { index, user in
                            leaderboardRow(rank: index + 1, user: user)
                        }
                    }

                    if sortedUsers.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "trophy")
                                .font(.system(size: 48))
                                .foregroundColor(GTTheme.textSecondary)
                            Text("No rankings yet")
                                .foregroundColor(GTTheme.textSecondary)
                            Text("Start answering trivia to climb the leaderboard!")
                                .font(.caption)
                                .foregroundColor(GTTheme.textSecondary.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            try? await authService.loadProfile()
            users = (try? await authService.getAllUsers()) ?? []
        }
        .onAppear {
            Task {
                try? await authService.loadProfile()
                users = (try? await authService.getAllUsers()) ?? []
            }
        }
    }

    // MARK: - Podium View
    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // 2nd place
            podiumItem(user: sortedUsers[1], rank: 2, height: 100, color: Color.gray)

            // 1st place
            podiumItem(user: sortedUsers[0], rank: 1, height: 130, color: GTTheme.techGold)

            // 3rd place
            if sortedUsers.count > 2 {
                podiumItem(user: sortedUsers[2], rank: 3, height: 80, color: Color.brown.opacity(0.7))
            }
        }
        .padding(.vertical, 12)
    }

    private func podiumItem(user: AppUser, rank: Int, height: CGFloat, color: Color) -> some View {
        VStack(spacing: 8) {
            // Avatar
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: rank == 1 ? 56 : 44, height: rank == 1 ? 56 : 44)

                Text(String(user.displayName.prefix(1)))
                    .font(rank == 1 ? .title2.bold() : .headline.bold())
                    .foregroundColor(GTTheme.navyBlue)
            }

            Text(user.displayName)
                .font(.caption.bold())
                .foregroundColor(.white)
                .lineLimit(1)

            Text("\(user.points) pts")
                .font(.caption2)
                .foregroundColor(color)

            // Podium block
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.3))
                .frame(height: height)
                .overlay(
                    Text("#\(rank)")
                        .font(.title.bold())
                        .foregroundColor(color)
                )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Leaderboard Row
    private func leaderboardRow(rank: Int, user: AppUser) -> some View {
        HStack(spacing: 14) {
            // Rank
            Text("\(rank)")
                .font(.headline.bold().monospacedDigit())
                .foregroundColor(rankColor(rank))
                .frame(width: 32)

            // Avatar
            ZStack {
                Circle()
                    .fill(rankColor(rank).opacity(0.3))
                    .frame(width: 40, height: 40)
                Text(String(user.displayName.prefix(1)))
                    .font(.headline.bold())
                    .foregroundColor(rankColor(rank))
            }

            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)

                if user.id == authService.currentUser?.id {
                    Text("YOU")
                        .font(.caption2.bold())
                        .foregroundColor(GTTheme.techGold)
                }
            }

            Spacer()

            // Points
            Text("\(user.points)")
                .font(.headline.bold().monospacedDigit())
                .foregroundColor(GTTheme.techGold)

            Text("pts")
                .font(.caption)
                .foregroundColor(GTTheme.textSecondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(user.id == authService.currentUser?.id
                      ? GTTheme.techGold.opacity(0.1)
                      : GTTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(user.id == authService.currentUser?.id
                        ? GTTheme.techGold.opacity(0.4)
                        : Color.clear, lineWidth: 1)
        )
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return GTTheme.techGold
        case 2: return Color.gray
        case 3: return Color.brown
        default: return GTTheme.textSecondary
        }
    }
}

#Preview {
    LeaderboardView()
}
