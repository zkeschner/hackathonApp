import Foundation

// MARK: - Rewards Service
class RewardsService: ObservableObject {
    static let shared = RewardsService()

    @Published var rewards: [Reward] = []
    @Published var redemptions: [Redemption] = []

    private let rewardsKey = "gt_athletics_rewards"
    private let redemptionsKey = "gt_athletics_redemptions"

    init() {
        loadRewards()
        loadRedemptions()
        seedSampleRewardsIfNeeded()
    }

    // MARK: - Reward Management (Admin)
    func addReward(_ reward: Reward) {
        rewards.append(reward)
        saveRewards()
    }

    func updateReward(_ reward: Reward) {
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards[index] = reward
            saveRewards()
        }
    }

    func deleteReward(_ rewardId: String) {
        rewards.removeAll { $0.id == rewardId }
        saveRewards()
    }

    // MARK: - Redemption
    func redeemReward(_ reward: Reward, for user: AppUser) -> Result<Redemption, RewardError> {
        guard user.points >= reward.pointCost else {
            return .failure(.insufficientPoints)
        }

        guard reward.quantityAvailable != 0 else {
            return .failure(.outOfStock)
        }

        // Deduct quantity
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            if rewards[index].quantityAvailable > 0 {
                rewards[index] = Reward(
                    id: rewards[index].id,
                    name: rewards[index].name,
                    description: rewards[index].description,
                    imageURL: rewards[index].imageURL,
                    pointCost: rewards[index].pointCost,
                    quantityAvailable: rewards[index].quantityAvailable - 1,
                    category: rewards[index].category,
                    isActive: rewards[index].isActive,
                    createdAt: rewards[index].createdAt
                )
            }
        }

        let redemption = Redemption(
            userId: user.id,
            rewardId: reward.id,
            rewardName: reward.name,
            pointsSpent: reward.pointCost
        )

        redemptions.append(redemption)
        saveRewards()
        saveRedemptions()

        // Deduct points from user
        var updatedUser = user
        updatedUser.points -= reward.pointCost
        AuthService.shared.updateUser(updatedUser)

        return .success(redemption)
    }

    // MARK: - Get User Redemptions
    func getRedemptions(for userId: String) -> [Redemption] {
        return redemptions.filter { $0.userId == userId }.sorted { $0.redeemedAt > $1.redeemedAt }
    }

    // MARK: - Get Available Rewards
    func getAvailableRewards() -> [Reward] {
        return rewards.filter { $0.isActive && $0.quantityAvailable != 0 }
    }

    func getRewardsByCategory(_ category: RewardCategory) -> [Reward] {
        return getAvailableRewards().filter { $0.category == category }
    }

    // MARK: - Persistence
    private func loadRewards() {
        guard let data = UserDefaults.standard.data(forKey: rewardsKey),
              let decoded = try? JSONDecoder().decode([Reward].self, from: data) else { return }
        rewards = decoded
    }

    private func saveRewards() {
        if let data = try? JSONEncoder().encode(rewards) {
            UserDefaults.standard.set(data, forKey: rewardsKey)
        }
    }

    private func loadRedemptions() {
        guard let data = UserDefaults.standard.data(forKey: redemptionsKey),
              let decoded = try? JSONDecoder().decode([Redemption].self, from: data) else { return }
        redemptions = decoded
    }

    private func saveRedemptions() {
        if let data = try? JSONEncoder().encode(redemptions) {
            UserDefaults.standard.set(data, forKey: redemptionsKey)
        }
    }

    // MARK: - Seed Sample Rewards
    private func seedSampleRewardsIfNeeded() {
        guard rewards.isEmpty else { return }

        let sampleRewards = [
            Reward(name: "GT T-Shirt", description: "Official Georgia Tech Athletics t-shirt in Tech Gold", pointCost: 100, quantityAvailable: 50, category: .merchandise),
            Reward(name: "GT Baseball Cap", description: "Navy blue GT fitted cap with embroidered Buzz logo", pointCost: 75, quantityAvailable: 30, category: .merchandise),
            Reward(name: "Football Game Tickets", description: "2 tickets to an upcoming GT home football game", pointCost: 500, quantityAvailable: 10, category: .tickets),
            Reward(name: "Meet the Coach", description: "Exclusive meet & greet with a GT head coach", pointCost: 1000, quantityAvailable: 3, category: .experiences),
            Reward(name: "Dining Hall Voucher", description: "$10 voucher for campus dining", pointCost: 50, quantityAvailable: -1, category: .food),
            Reward(name: "GT Phone Wallpaper Pack", description: "Exclusive digital wallpapers featuring GT Athletics", pointCost: 15, quantityAvailable: -1, category: .digital),
            Reward(name: "Sideline Pass", description: "Walk the sideline before a GT home game", pointCost: 750, quantityAvailable: 5, category: .experiences)
        ]

        rewards = sampleRewards
        saveRewards()
    }
}

// MARK: - Reward Errors
enum RewardError: LocalizedError {
    case insufficientPoints
    case outOfStock

    var errorDescription: String? {
        switch self {
        case .insufficientPoints: return "You don't have enough points for this reward."
        case .outOfStock: return "This reward is currently out of stock."
        }
    }
}
