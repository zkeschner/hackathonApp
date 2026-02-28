import Foundation

// MARK: - Trivia Service
class TriviaService: ObservableObject {
    static let shared = TriviaService()

    @Published var videos: [TriviaVideo] = []
    @Published var activeVideo: TriviaVideo?

    private let videosKey = "gt_athletics_videos"
    private let answersKey = "gt_athletics_answers"

    init() {
        loadVideos()
        seedSampleDataIfNeeded()
    }

    // MARK: - Video Management (Admin)
    func uploadVideo(_ video: TriviaVideo) {
        var v = video
        v = TriviaVideo(
            id: video.id,
            title: video.title,
            description: video.description,
            videoURL: video.videoURL,
            thumbnailURL: video.thumbnailURL,
            scheduledTime: video.scheduledTime,
            isActive: video.isActive,
            question: video.question,
            uploadedBy: video.uploadedBy,
            createdAt: video.createdAt
        )
        videos.append(v)
        saveVideos()
    }

    func deleteVideo(_ videoId: String) {
        videos.removeAll { $0.id == videoId }
        saveVideos()
    }

    func activateVideo(_ videoId: String) {
        // Deactivate all, activate selected
        for i in 0..<videos.count {
            videos[i] = TriviaVideo(
                id: videos[i].id,
                title: videos[i].title,
                description: videos[i].description,
                videoURL: videos[i].videoURL,
                thumbnailURL: videos[i].thumbnailURL,
                scheduledTime: videos[i].scheduledTime,
                isActive: videos[i].id == videoId,
                question: videos[i].question,
                uploadedBy: videos[i].uploadedBy,
                createdAt: videos[i].createdAt
            )
        }
        activeVideo = videos.first(where: { $0.id == videoId })
        saveVideos()
    }

    // MARK: - Answer Submission
    func submitAnswer(userId: String, videoId: String, questionId: String, selectedIndex: Int) -> (correct: Bool, points: Int) {
        guard let video = videos.first(where: { $0.id == videoId }) else {
            return (false, 0)
        }

        // Check if already answered
        if hasAnswered(userId: userId, videoId: videoId) {
            return (false, 0)
        }

        let isCorrect = video.question.correctAnswerIndex == selectedIndex
        let points = isCorrect ? video.question.pointValue : 0

        // Save answer record
        saveAnswer(userId: userId, videoId: videoId, correct: isCorrect)

        return (isCorrect, points)
    }

    func hasAnswered(userId: String, videoId: String) -> Bool {
        let answers = loadAnswers()
        return answers.contains("\(userId)_\(videoId)")
    }

    // MARK: - Get Active / Upcoming
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

    // MARK: - Persistence
    private func loadVideos() {
        guard let data = UserDefaults.standard.data(forKey: videosKey),
              let decoded = try? JSONDecoder().decode([TriviaVideo].self, from: data) else { return }
        videos = decoded
        activeVideo = videos.first(where: { $0.isActive })
    }

    private func saveVideos() {
        if let data = try? JSONEncoder().encode(videos) {
            UserDefaults.standard.set(data, forKey: videosKey)
        }
    }

    private func loadAnswers() -> Set<String> {
        let arr = UserDefaults.standard.stringArray(forKey: answersKey) ?? []
        return Set(arr)
    }

    private func saveAnswer(userId: String, videoId: String, correct: Bool) {
        var answers = loadAnswers()
        answers.insert("\(userId)_\(videoId)")
        UserDefaults.standard.set(Array(answers), forKey: answersKey)
    }

    // MARK: - Seed Sample Data
    private func seedSampleDataIfNeeded() {
        guard videos.isEmpty else { return }

        let sampleVideos = [
            TriviaVideo(
                title: "GT Football Highlights",
                description: "Watch these amazing plays and answer the trivia question!",
                videoURL: "https://example.com/video1.mp4",
                thumbnailURL: nil,
                scheduledTime: Date(),
                isActive: true,
                question: TriviaQuestion(
                    questionText: "How many national championships has Georgia Tech football won?",
                    options: ["2", "3", "4", "5"],
                    correctAnswerIndex: 2,
                    pointValue: 10
                ),
                uploadedBy: "admin"
            ),
            TriviaVideo(
                title: "Buzz Mascot History",
                description: "Learn about Georgia Tech's beloved mascot!",
                videoURL: "https://example.com/video2.mp4",
                thumbnailURL: nil,
                scheduledTime: Date().addingTimeInterval(86400 * 7),
                isActive: false,
                question: TriviaQuestion(
                    questionText: "What year did Buzz become the official GT mascot?",
                    options: ["1972", "1979", "1980", "1985"],
                    correctAnswerIndex: 1,
                    pointValue: 10
                ),
                uploadedBy: "admin"
            ),
            TriviaVideo(
                title: "Basketball Season Preview",
                description: "Get hyped for the upcoming basketball season!",
                videoURL: "https://example.com/video3.mp4",
                thumbnailURL: nil,
                scheduledTime: Date().addingTimeInterval(86400 * 14),
                isActive: false,
                question: TriviaQuestion(
                    questionText: "Where do the Yellow Jackets play home basketball games?",
                    options: ["Bobby Dodd Stadium", "McCamish Pavilion", "Russ Chandler Stadium", "O'Keefe Gymnasium"],
                    correctAnswerIndex: 1,
                    pointValue: 15
                ),
                uploadedBy: "admin"
            )
        ]

        videos = sampleVideos
        activeVideo = sampleVideos.first
        saveVideos()
    }
}
