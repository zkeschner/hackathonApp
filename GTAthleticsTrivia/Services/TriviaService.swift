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

// MARK: - Trivia Service (Supabase)
@MainActor
class TriviaService: ObservableObject {
    static let shared = TriviaService()

    @Published var videos: [TriviaVideo] = []
    @Published var activeVideo: TriviaVideo?

    init() {
        Task { await fetchVideos() }
    }

    // MARK: - Fetch Videos
    func fetchVideos() async {
        do {
            let fetched: [TriviaVideo] = try await supabase.from("trivia_videos")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            videos = fetched
            activeVideo = fetched.first(where: { $0.isActive })
        } catch {
            print("Error fetching videos: \(error)")
        }
    }

    // MARK: - Video Management (Admin)
    func uploadVideo(_ video: TriviaVideo) async throws {
        try await supabase.from("trivia_videos").insert(video).execute()
        await fetchVideos()
    }

    func deleteVideo(_ videoId: String) async throws {
        try await supabase.from("trivia_videos")
            .delete()
            .eq("id", value: videoId)
            .execute()
        await fetchVideos()
    }

    private struct DeactivatePayload: Encodable {
        let is_active: Bool
        let activated_at: String?
    }

    private struct ActivatePayload: Encodable {
        let is_active: Bool
        let activated_at: String
    }

    func activateVideo(_ videoId: String) async throws {
        // Deactivate all
        try await supabase.from("trivia_videos")
            .update(DeactivatePayload(is_active: false, activated_at: nil))
            .eq("is_active", value: true)
            .execute()

        // Activate selected and set activated_at
        let isoDate = ISO8601DateFormatter().string(from: Date())
        try await supabase.from("trivia_videos")
            .update(ActivatePayload(is_active: true, activated_at: isoDate))
            .eq("id", value: videoId)
            .execute()

        await fetchVideos()

        // Schedule auto-deactivation via Edge Function after 30 seconds
        Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            try? await supabase.functions.invoke("deactivation")
            await fetchVideos()
        }
    }

    // MARK: - Answer Submission
    func submitAnswer(userId: String, videoId: String, selectedIndex: Int) async throws -> (correct: Bool, points: Int) {
        guard let video = videos.first(where: { $0.id == videoId }) else {
            return (false, 0)
        }

        // Check if already answered
        let alreadyAnswered = await hasAnswered(userId: userId, videoId: videoId)
        if alreadyAnswered {
            return (false, 0)
        }

        let isCorrect = video.correctAnswerIndex == selectedIndex
        let points = isCorrect ? video.pointValue : 0

        // Save answer record
        let answer = AnswerRecord(
            userId: userId,
            videoId: videoId,
            selectedIndex: selectedIndex,
            isCorrect: isCorrect,
            pointsEarned: points
        )
        try await supabase.from("answers").insert(answer).execute()

        // Update user points if correct
        if points > 0 {
            try await supabase.rpc("increment_points", params: IncrementPointsParams(userIdInput: userId, pointsInput: points)).execute()
        }

        return (isCorrect, points)
    }

    func hasAnswered(userId: String, videoId: String) async -> Bool {
        do {
            let results: [AnswerRecord] = try await supabase.from("answers")
                .select()
                .eq("user_id", value: userId)
                .eq("video_id", value: videoId)
                .execute()
                .value
            return !results.isEmpty
        } catch {
            return false
        }
    }

    // MARK: - Convenience Getters
    func getActiveVideo() -> TriviaVideo? {
        return videos.first(where: { $0.isActive })
    }

    func getPastVideos() -> [TriviaVideo] {
        return videos.filter { !$0.isActive }
    }
}
