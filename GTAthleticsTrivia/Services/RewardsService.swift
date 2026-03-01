import Foundation
import Supabase

private struct IncrementPointsParams: Encodable {
    let userIdInput: String
    let pointsInput: Int

    enum CodingKeys: String, CodingKey {
        case userIdInput = "user_id_input"
        case pointsInput = "points_input"
    }
}

// MARK: - Rewards Service (Supabase)
@MainActor
class RewardsService: ObservableObject {
    static let shared = RewardsService()

    @Published var rewards: [Reward] = []
    @Published var redemptions: [Redemption] = []

    init() {
        Task { await fetchRewards() }
    }

    // MARK: - Fetch Rewards
    func fetchRewards() async {
        do {
            let fetched: [Reward] = try await supabase.from("rewards")
                .select()
                .order("point_cost", ascending: true)
                .execute()
                .value
            rewards = fetched
        } catch {
            print("Error fetching rewards: \(error)")
        }
    }

    // MARK: - Reward Management (Admin)
    func addReward(_ reward: Reward) async throws {
        try await supabase.from("rewards").insert(reward).execute()
        await fetchRewards()
    }

    func updateReward(_ reward: Reward) async throws {
        try await supabase.from("rewards")
            .update(reward)
            .eq("id", value: reward.id)
            .execute()
        await fetchRewards()
    }

    func deleteReward(_ rewardId: String) async throws {
        try await supabase.from("rewards")
            .delete()
            .eq("id", value: rewardId)
            .execute()
        await fetchRewards()
    }

    // MARK: - Redemption
    func redeemReward(_ reward: Reward, for user: AppUser) async throws {
        guard user.points >= reward.pointCost else {
            throw RewardError.insufficientPoints
        }

        guard reward.quantityAvailable != 0 else {
            throw RewardError.outOfStock
        }

        // Create redemption record
        let redemption = Redemption(
            userId: user.id,
            rewardId: reward.id,
            rewardName: reward.name,
            pointsSpent: reward.pointCost
        )
        try await supabase.from("redemptions").insert(redemption).execute()

        // Deduct quantity if limited
        if reward.quantityAvailable > 0 {
            try await supabase.from("rewards")
                .update(["quantity_available": reward.quantityAvailable - 1])
                .eq("id", value: reward.id)
                .execute()
        }

        // Deduct points
        try await supabase.rpc("increment_points", params: IncrementPointsParams(userIdInput: user.id, pointsInput: -reward.pointCost)).execute()

        // Refresh local data
        await fetchRewards()
        await fetchRedemptions(for: user.id)

        // Refresh user profile
        try await AuthService.shared.updateUser(
            AppUser(id: user.id, email: user.email, displayName: user.displayName, points: user.points - reward.pointCost, isAdmin: user.isAdmin)
        )
    }

    // MARK: - Get User Redemptions
    func fetchRedemptions(for userId: String) async {
        do {
            let fetched: [Redemption] = try await supabase.from("redemptions")
                .select()
                .eq("user_id", value: userId)
                .order("redeemed_at", ascending: false)
                .execute()
                .value
            redemptions = fetched
        } catch {
            print("Error fetching redemptions: \(error)")
        }
    }

    // MARK: - Convenience
    func getAvailableRewards() -> [Reward] {
        return rewards.filter { $0.quantityAvailable != 0 }
    }

    func getRewardsByCategory(_ category: RewardCategory) -> [Reward] {
        return getAvailableRewards().filter { $0.category == category.rawValue }
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
