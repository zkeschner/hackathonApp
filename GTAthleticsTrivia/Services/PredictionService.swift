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

// MARK: - Prediction Service (Supabase)
@MainActor
class PredictionService: ObservableObject {
    static let shared = PredictionService()

    @Published var predictions: [Prediction] = []
    @Published var userVotes: [PredictionVote] = []

    init() {
        Task { await fetchPredictions() }
    }

    // MARK: - Fetch Predictions
    func fetchPredictions() async {
        do {
            let fetched: [Prediction] = try await supabase.from("predictions")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            predictions = fetched
        } catch {
            print("Error fetching predictions: \(error)")
        }
    }

    // MARK: - Fetch User Votes
    func fetchUserVotes(userId: String) async {
        do {
            let fetched: [PredictionVote] = try await supabase.from("prediction_votes")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            userVotes = fetched
        } catch {
            print("Error fetching votes: \(error)")
        }
    }

    // MARK: - Admin: Create Prediction
    func createPrediction(_ prediction: Prediction) async throws {
        try await supabase.from("predictions").insert(prediction).execute()
        await fetchPredictions()
    }

    // MARK: - Admin: Delete Prediction
    func deletePrediction(_ predictionId: String) async throws {
        try await supabase.from("predictions")
            .delete()
            .eq("id", value: predictionId)
            .execute()
        await fetchPredictions()
    }

    // MARK: - Admin: Close Prediction & Pay Out
    private struct ClosePredictionPayload: Encodable {
        let is_active: Bool
        let is_closed: Bool
        let correct_answer: Bool
        let closed_at: String
    }

    func closePrediction(_ predictionId: String, correctAnswer: Bool) async throws {
        let prediction = predictions.first(where: { $0.id == predictionId })
        guard let prediction = prediction else { return }

        // Close the prediction
        let isoDate = ISO8601DateFormatter().string(from: Date())
        try await supabase.from("predictions")
            .update(ClosePredictionPayload(
                is_active: false,
                is_closed: true,
                correct_answer: correctAnswer,
                closed_at: isoDate
            ))
            .eq("id", value: predictionId)
            .execute()

        // Get all votes for this prediction
        let allVotes: [PredictionVote] = try await supabase.from("prediction_votes")
            .select()
            .eq("prediction_id", value: predictionId)
            .execute()
            .value

        // Pay out correct voters
        let pointsToAward = Int(Double(prediction.pointValue) * PointsMultiplier.current)
        for vote in allVotes where vote.vote == correctAnswer {
            // Update vote record with points earned
            try await supabase.from("prediction_votes")
                .update(["points_earned": pointsToAward])
                .eq("id", value: vote.id)
                .execute()

            // Award points to user
            try await supabase.rpc("increment_points", params: IncrementPointsParams(
                userIdInput: vote.userId,
                pointsInput: pointsToAward
            )).execute()
        }

        await fetchPredictions()
    }

    // MARK: - User: Submit Vote
    func submitVote(userId: String, predictionId: String, vote: Bool) async throws {
        // Check if already voted
        if hasVoted(userId: userId, predictionId: predictionId) {
            return
        }

        let predictionVote = PredictionVote(
            userId: userId,
            predictionId: predictionId,
            vote: vote,
            pointsEarned: 0
        )
        try await supabase.from("prediction_votes").insert(predictionVote).execute()
        await fetchUserVotes(userId: userId)
    }

    // MARK: - Convenience
    func hasVoted(userId: String, predictionId: String) -> Bool {
        return userVotes.contains { $0.userId == userId && $0.predictionId == predictionId }
    }

    func getUserVote(userId: String, predictionId: String) -> PredictionVote? {
        return userVotes.first { $0.userId == userId && $0.predictionId == predictionId }
    }

    func getActivePredictions() -> [Prediction] {
        return predictions.filter { $0.isActive && !$0.isClosed }
    }

    func getClosedPredictions() -> [Prediction] {
        return predictions.filter { $0.isClosed }
    }
}
