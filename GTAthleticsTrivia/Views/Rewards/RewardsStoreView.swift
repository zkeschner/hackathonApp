import SwiftUI

struct RewardsStoreView: View {
    @StateObject private var viewModel = RewardsViewModel()
    @ObservedObject var authService = AuthService.shared
    @State private var showRedemptions = false

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Points Balance
                    pointsBalanceCard

                    // Category Filter
                    categoryFilter

                    // Rewards Grid
                    rewardsGrid

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showRedemptions = true }) {
                    Image(systemName: "bag.fill")
                        .foregroundColor(GTTheme.techGold)
                }
            }
        }
        .sheet(isPresented: $showRedemptions) {
            RedemptionHistoryView(redemptions: viewModel.userRedemptions)
        }
        .alert(viewModel.isSuccess ? "Success!" : "Oops", isPresented: $viewModel.showMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.redemptionMessage)
        }
    }

    // MARK: - Points Balance Card
    private var pointsBalanceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("AVAILABLE POINTS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(2)
                    .foregroundColor(GTTheme.techGold.opacity(0.8))

                Text("\(authService.currentUser?.points ?? 0)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(GTTheme.techGold)
            }

            Spacer()

            Image(systemName: "gift.fill")
                .font(.system(size: 36))
                .foregroundColor(GTTheme.techGold)
        }
        .gtCard()
        .padding(.top, 16)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryChip(title: "All", category: nil)
                ForEach(RewardCategory.allCases, id: \.self) { category in
                    categoryChip(title: category.rawValue, category: category)
                }
            }
        }
    }

    private func categoryChip(title: String, category: RewardCategory?) -> some View {
        Button(action: { viewModel.selectedCategory = category }) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(viewModel.selectedCategory == category
                              ? GTTheme.techGold
                              : GTTheme.cardBackground)
                )
                .foregroundColor(viewModel.selectedCategory == category
                                 ? GTTheme.navyBlue
                                 : GTTheme.textSecondary)
                .overlay(
                    Capsule()
                        .stroke(GTTheme.techGold.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - Rewards Grid
    private var rewardsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ], spacing: 14) {
            ForEach(viewModel.rewards) { reward in
                RewardCard(
                    reward: reward,
                    userPoints: authService.currentUser?.points ?? 0,
                    onRedeem: { viewModel.redeemReward(reward) }
                )
            }
        }
    }
}

// MARK: - Reward Card
struct RewardCard: View {
    let reward: Reward
    let userPoints: Int
    let onRedeem: () -> Void

    var canAfford: Bool { userPoints >= reward.pointCost }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(GTTheme.navyBlue)
                    .frame(height: 100)

                Image(systemName: categoryIcon)
                    .font(.system(size: 30))
                    .foregroundColor(GTTheme.techGold)
            }

            Text(reward.name)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .lineLimit(2)

            Text(reward.description)
                .font(.caption2)
                .foregroundColor(GTTheme.textSecondary)
                .lineLimit(2)

            Spacer()

            HStack {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text("\(reward.pointCost)")
                        .font(.caption.bold())
                }
                .foregroundColor(GTTheme.techGold)

                Spacer()
            }

            Button(action: onRedeem) {
                Text(canAfford ? "Redeem" : "Need \(reward.pointCost - userPoints) more")
                    .font(.caption2.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(canAfford ? GTTheme.techGold : GTTheme.textSecondary.opacity(0.3))
                    )
                    .foregroundColor(canAfford ? GTTheme.navyBlue : GTTheme.textSecondary)
            }
            .disabled(!canAfford)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(GTTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(GTTheme.techGold.opacity(0.15), lineWidth: 1)
        )
    }

    var categoryIcon: String {
        switch reward.category {
        case "Merchandise": return "tshirt.fill"
        case "Tickets": return "ticket.fill"
        case "Experiences": return "star.circle.fill"
        case "Food": return "fork.knife"
        case "Digital": return "iphone"
        default: return "gift.fill"
        }
    }
}

// MARK: - Redemption History
struct RedemptionHistoryView: View {
    let redemptions: [Redemption]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("My Redemptions")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(GTTheme.textSecondary)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                if redemptions.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bag")
                            .font(.system(size: 48))
                            .foregroundColor(GTTheme.textSecondary)
                        Text("No redemptions yet")
                            .foregroundColor(GTTheme.textSecondary)
                    }
                    Spacer()
                } else {
                    List(redemptions) { redemption in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(redemption.rewardName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)

                                Text(redemption.redeemedAt ?? Date(), style: .date)
                                    .font(.caption)
                                    .foregroundColor(GTTheme.textSecondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("-\(redemption.pointsSpent) pts")
                                    .font(.caption.bold())
                                    .foregroundColor(GTTheme.techGold)

                                Text(redemption.status)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(statusColor(redemption.status).opacity(0.2)))
                                    .foregroundColor(statusColor(redemption.status))
                            }
                        }
                        .listRowBackground(GTTheme.cardBackground)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "pending": return .orange
        case "fulfilled": return GTTheme.success
        case "cancelled": return GTTheme.error
        default: return GTTheme.textSecondary
        }
    }
}

#Preview {
    NavigationStack {
        RewardsStoreView()
    }
}
