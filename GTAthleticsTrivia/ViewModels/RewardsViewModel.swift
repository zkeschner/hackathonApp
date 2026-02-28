import Foundation
import SwiftUI

// MARK: - Rewards ViewModel
@MainActor
class RewardsViewModel: ObservableObject {
    @Published var selectedCategory: RewardCategory? = nil
    @Published var showRedeemConfirmation = false
    @Published var selectedReward: Reward?
    @Published var redemptionMessage = ""
    @Published var showMessage = false
    @Published var isSuccess = false

    private let rewardsService = RewardsService.shared

    var rewards: [Reward] {
        if let category = selectedCategory {
            return rewardsService.getRewardsByCategory(category)
        }
        return rewardsService.getAvailableRewards()
    }

    var userRedemptions: [Redemption] {
        return rewardsService.redemptions
    }

    func loadRedemptions() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        Task { await rewardsService.fetchRedemptions(for: userId) }
    }

    func redeemReward(_ reward: Reward) {
        guard let user = AuthService.shared.currentUser else { return }

        Task {
            do {
                try await rewardsService.redeemReward(reward, for: user)
                redemptionMessage = "Successfully redeemed \(reward.name)! 🎉"
                isSuccess = true
            } catch {
                redemptionMessage = error.localizedDescription
                isSuccess = false
            }
            showMessage = true
        }
    }
}

// MARK: - Admin ViewModel
@MainActor
class AdminViewModel: ObservableObject {
    @Published var videoTitle = ""
    @Published var videoDescription = ""
    @Published var videoURL = ""
    @Published var scheduledDate = Date()
    @Published var questionText = ""
    @Published var options = ["", "", "", ""]
    @Published var correctAnswerIndex = 0
    @Published var pointValue = 10
    @Published var timeLimitSeconds = 30

    @Published var rewardName = ""
    @Published var rewardDescription = ""
    @Published var rewardPointCost = 50
    @Published var rewardQuantity = -1
    @Published var rewardCategory: RewardCategory = .merchandise

    @Published var message = ""
    @Published var showMessage = false

    private let triviaService = TriviaService.shared
    private let rewardsService = RewardsService.shared

    var allVideos: [TriviaVideo] {
        triviaService.videos
    }

    var allRewards: [Reward] {
        rewardsService.rewards
    }

    // MARK: - Upload Video + Question
    func uploadVideo() {
        guard !videoTitle.isEmpty, !videoURL.isEmpty, !questionText.isEmpty else {
            message = "Please fill in all required fields."
            showMessage = true
            return
        }

        let filledOptions = options.filter { !$0.isEmpty }
        guard filledOptions.count >= 2 else {
            message = "Please provide at least 2 answer options."
            showMessage = true
            return
        }

        let video = TriviaVideo(
            title: videoTitle,
            description: videoDescription,
            videoURL: videoURL,
            scheduledTime: scheduledDate,
            isActive: false,
            questionText: questionText,
            options: filledOptions,
            correctAnswerIndex: correctAnswerIndex,
            pointValue: pointValue,
            timeLimitSeconds: timeLimitSeconds,
            uploadedBy: AuthService.shared.currentUser?.id ?? "admin"
        )

        Task {
            do {
                try await triviaService.uploadVideo(video)
                message = "Video uploaded successfully!"
            } catch {
                message = "Upload failed: \(error.localizedDescription)"
            }
            showMessage = true
        }
        clearVideoForm()
    }

    func activateVideo(_ videoId: String) {
        Task {
            do {
                try await triviaService.activateVideo(videoId)
                message = "Video is now live!"
            } catch {
                message = "Activation failed: \(error.localizedDescription)"
            }
            showMessage = true
        }
    }

    func deleteVideo(_ videoId: String) {
        Task { try? await triviaService.deleteVideo(videoId) }
    }

    // MARK: - Add Reward
    func addReward() {
        guard !rewardName.isEmpty, !rewardDescription.isEmpty else {
            message = "Please fill in reward name and description."
            showMessage = true
            return
        }

        let reward = Reward(
            name: rewardName,
            description: rewardDescription,
            pointCost: rewardPointCost,
            quantityAvailable: rewardQuantity,
            category: rewardCategory.rawValue
        )

        Task {
            do {
                try await rewardsService.addReward(reward)
                message = "Reward added successfully!"
            } catch {
                message = "Failed: \(error.localizedDescription)"
            }
            showMessage = true
        }
        clearRewardForm()
    }

    func deleteReward(_ rewardId: String) {
        Task { try? await rewardsService.deleteReward(rewardId) }
    }

    // MARK: - Helpers
    private func clearVideoForm() {
        videoTitle = ""
        videoDescription = ""
        videoURL = ""
        questionText = ""
        options = ["", "", "", ""]
        correctAnswerIndex = 0
        pointValue = 10
        timeLimitSeconds = 30
    }

    private func clearRewardForm() {
        rewardName = ""
        rewardDescription = ""
        rewardPointCost = 50
        rewardQuantity = -1
        rewardCategory = .merchandise
    }
}
