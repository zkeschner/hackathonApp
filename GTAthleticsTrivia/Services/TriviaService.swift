import Foundation
import Supabase

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
                .order("scheduled_time", ascending: false)
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

    func activateVideo(_ videoId: String) async throws {
        // Deactivate all
        try await supabase.from("trivia_videos")
            .update(["is_active": false])
            .eq("is_active", value: true)
            .execute()

        // Activate selected
        try await supabase.from("trivia_videos")
            .update(["is_active": true])
            .eq("id", value: videoId)
            .execute()

        await fetchVideos()
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
            pointsAwarded: points
        )
        try await supabase.from("answers").insert(answer).execute()

        // Update user points if correct
        if points > 0 {
            try await supabase.rpc("increment_points", params: ["user_id_input": userId, "points_input": points]).execute()
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

    func getUpcomingVideos() -> [TriviaVideo] {
        return videos
            .filter { $0.scheduledTime > Date() && !$0.isActive }
            .sorted { $0.scheduledTime < $1.scheduledTime }
    }

    func getPastVideos() -> [TriviaVideo] {
        return videos
            .filter { $0.scheduledTime <= Date() && !$0.isActive }
            .sorted { $0.scheduledTime > $1.scheduledTime }
    }
}
