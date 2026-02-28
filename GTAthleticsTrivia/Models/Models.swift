import Foundation

// MARK: - User Model
struct AppUser: Identifiable, Codable, Equatable {
    let id: String
    var email: String
    var displayName: String
    var points: Int
    var isAdmin: Bool
    var avatarURL: String?
    var weeklyScores: [WeeklyScore]
    var createdAt: Date

    init(id: String = UUID().uuidString, email: String, displayName: String, points: Int = 0, isAdmin: Bool = false, avatarURL: String? = nil, weeklyScores: [WeeklyScore] = [], createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.points = points
        self.isAdmin = isAdmin
        self.avatarURL = avatarURL
        self.weeklyScores = weeklyScores
        self.createdAt = createdAt
    }
}

// MARK: - Weekly Score
struct WeeklyScore: Codable, Equatable, Identifiable {
    var id: String { "\(weekNumber)-\(year)" }
    let weekNumber: Int
    let year: Int
    var score: Int
    var questionsAnswered: Int
    var questionsCorrect: Int
}

// MARK: - Trivia Video
struct TriviaVideo: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var description: String
    var videoURL: String
    var thumbnailURL: String?
    var scheduledTime: Date
    var isActive: Bool
    var question: TriviaQuestion
    var uploadedBy: String
    var createdAt: Date

    init(id: String = UUID().uuidString, title: String, description: String = "", videoURL: String, thumbnailURL: String? = nil, scheduledTime: Date, isActive: Bool = false, question: TriviaQuestion, uploadedBy: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.scheduledTime = scheduledTime
        self.isActive = isActive
        self.question = question
        self.uploadedBy = uploadedBy
        self.createdAt = createdAt
    }
}

// MARK: - Trivia Question
struct TriviaQuestion: Identifiable, Codable, Equatable {
    let id: String
    var questionText: String
    var options: [String]
    var correctAnswerIndex: Int
    var pointValue: Int
    var timeLimitSeconds: Int

    init(id: String = UUID().uuidString, questionText: String, options: [String], correctAnswerIndex: Int, pointValue: Int = 10, timeLimitSeconds: Int = 30) {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.pointValue = pointValue
        self.timeLimitSeconds = timeLimitSeconds
    }
}

// MARK: - Reward / Prize
struct Reward: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var description: String
    var imageURL: String?
    var pointCost: Int
    var quantityAvailable: Int
    var category: RewardCategory
    var isActive: Bool
    var createdAt: Date

    init(id: String = UUID().uuidString, name: String, description: String, imageURL: String? = nil, pointCost: Int, quantityAvailable: Int = -1, category: RewardCategory = .merchandise, isActive: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.pointCost = pointCost
        self.quantityAvailable = quantityAvailable
        self.category = category
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

enum RewardCategory: String, Codable, CaseIterable {
    case merchandise = "Merchandise"
    case tickets = "Tickets"
    case experiences = "Experiences"
    case food = "Food & Drink"
    case digital = "Digital"
}

// MARK: - Redemption Record
struct Redemption: Identifiable, Codable {
    let id: String
    let userId: String
    let rewardId: String
    let rewardName: String
    let pointsSpent: Int
    let redeemedAt: Date
    var status: RedemptionStatus

    init(id: String = UUID().uuidString, userId: String, rewardId: String, rewardName: String, pointsSpent: Int, redeemedAt: Date = Date(), status: RedemptionStatus = .pending) {
        self.id = id
        self.userId = userId
        self.rewardId = rewardId
        self.rewardName = rewardName
        self.pointsSpent = pointsSpent
        self.redeemedAt = redeemedAt
        self.status = status
    }
}

enum RedemptionStatus: String, Codable {
    case pending = "Pending"
    case fulfilled = "Fulfilled"
    case cancelled = "Cancelled"
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable {
    let id: String
    let displayName: String
    let points: Int
    let rank: Int
    let avatarURL: String?
}

// MARK: - Answer Submission
struct AnswerSubmission {
    let videoId: String
    let questionId: String
    let selectedIndex: Int
    let answeredAt: Date
    let timeToAnswer: TimeInterval
}
