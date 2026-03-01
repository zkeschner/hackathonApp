import Foundation
import SwiftUI

// MARK: - Prediction ViewModel
@MainActor
class PredictionViewModel: ObservableObject {
    @Published var activePredictions: [Prediction] = []
    @Published var closedPredictions: [Prediction] = []
    @Published var showResult = false
    @Published var resultMessage = ""

    private let predictionService = PredictionService.shared
    private let authService = AuthService.shared
    private var pollTimer: Timer?

    func load() {
        Task {
            await predictionService.fetchPredictions()
            if let user = authService.currentUser {
                await predictionService.fetchUserVotes(userId: user.id)
            }
            activePredictions = predictionService.getActivePredictions()
            closedPredictions = predictionService.getClosedPredictions()
        }
    }

    func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.load() }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    func hasVoted(predictionId: String) -> Bool {
        guard let user = authService.currentUser else { return false }
        return predictionService.hasVoted(userId: user.id, predictionId: predictionId)
    }

    func getUserVote(predictionId: String) -> PredictionVote? {
        guard let user = authService.currentUser else { return nil }
        return predictionService.getUserVote(userId: user.id, predictionId: predictionId)
    }

    func submitVote(predictionId: String, vote: Bool) {
        guard let user = authService.currentUser else { return }
        Task {
            do {
                try await predictionService.submitVote(userId: user.id, predictionId: predictionId, vote: vote)
                resultMessage = "Vote submitted!"
                showResult = true
                load()
            } catch {
                resultMessage = "Failed to submit vote: \(error.localizedDescription)"
                showResult = true
            }
        }
    }

    deinit {
        pollTimer?.invalidate()
    }
}
