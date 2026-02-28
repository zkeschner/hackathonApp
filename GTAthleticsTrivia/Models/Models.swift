import Foundation

// MARK: - User Profile (maps to "profiles" table)
struct AppUser: Identifiable, Codable, Equatable {
    let id: String
    var email: String
    var displayName: String
    var points: Int
    var isAdmin: Bool
    var avatarURL: String?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case points
        case isAdmin = "is_admin"
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }

    init(id: String = UUID().uuidString, email: String, displayName: String, points: Int = 0, isAdmin: Bool = false, avatarURL: String? = nil, createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.points = points
        self.isAdmin = isAdmin
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }
}

// MARK: - Trivia Video (maps to "trivia_videos" table)
struct TriviaVideo: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var description: String
    var videoURL: String
    var thumbnailURL: String?
    var scheduledTime: Date
    var isActive: Bool
    var questionText: String
    var options: [String]
    var correctAnswerIndex: Int
    var pointValue: Int
    var timeLimitSeconds: Int
    var uploadedBy: String
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case videoURL = "video_url"
        case thumbnailURL = "thumbnail_url"
        case scheduledTime = "scheduled_time"
        case isActive = "is_active"
        case questionText = "question_text"
        case options
        case correctAnswerIndex = "correct_answer_index"
        case pointValue = "point_value"
        case timeLimitSeconds = "time_limit_seconds"
        case uploadedBy = "uploaded_by"
        case createdAt = "created_at"
    }

    init(id: String = UUID().uuidString, title: String, description: String = "", videoURL: String, thumbnailURL: String? = nil, scheduledTime: Date, isActive: Bool = false, questionText: String, options: [String], correctAnswerIndex: Int, pointValue: Int = 10, timeLimitSeconds: Int = 30, uploadedBy: String, createdAt: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.scheduledTime = scheduledTime
        self.isActive = isActive
        self.questionText = questionText
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.pointValue = pointValue
        self.timeLimitSeconds = timeLimitSeconds
        self.uploadedBy = uploadedBy
        self.createdAt = createdAt
    }
}

// MARK: - Answer Record (maps to "answers" table)
struct AnswerRecord: Identifiable, Codable {
    let id: String
    let userId: String
    let videoId: String
    let selectedIndex: Int
    let isCorrect: Bool
    let pointsAwarded: Int
    let answeredAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case videoId = "video_id"
        case selectedIndex = "selected_index"
        case isCorrect = "is_correct"
        case pointsAwarded = "points_awarded"
        case answeredAt = "answered_at"
    }

    init(id: String = UUID().uuidString, userId: String, videoId: String, selectedIndex: Int, isCorrect: Bool, pointsAwarded: Int, answeredAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.videoId = videoId
        self.selectedIndex = selectedIndex
        self.isCorrect = isCorrect
        self.pointsAwarded = pointsAwarded
        self.answeredAt = answeredAt
    }
}

// MARK: - Reward / Prize (maps to "rewards" table)
struct Reward: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var description: String
    var imageURL: String?
    var pointCost: Int
    var quantityAvailable: Int
    var category: String
    var isActive: Bool
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageURL = "image_url"
        case pointCost = "point_cost"
        case quantityAvailable = "quantity_available"
        case category
        case isActive = "is_active"
        case createdAt = "created_at"
    }

    init(id: String = UUID().uuidString, name: String, description: String, imageURL: String? = nil, pointCost: Int, quantityAvailable: Int = -1, category: String = "Merchandise", isActive: Bool = true, createdAt: Date? = nil) {
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

enum RewardCategory: String, CaseIterable {
    case merchandise = "Merchandise"
    case tickets = "Tickets"
    case experiences = "Experiences"
    case food = "Food & Drink"
    case digital = "Digital"
}

// MARK: - Redemption Record (maps to "redemptions" table)
struct Redemption: Identifiable, Codable {
    let id: String
    let userId: String
    let rewardId: String
    let rewardName: String
    let pointsSpent: Int
    let redeemedAt: Date?
    var status: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case rewardId = "reward_id"
        case rewardName = "reward_name"
        case pointsSpent = "points_spent"
        case redeemedAt = "redeemed_at"
        case status
    }

    init(id: String = UUID().uuidString, userId: String, rewardId: String, rewardName: String, pointsSpent: Int, redeemedAt: Date? = nil, status: String = "Pending") {
        self.id = id
        self.userId = userId
        self.rewardId = rewardId
        self.rewardName = rewardName
        self.pointsSpent = pointsSpent
        self.redeemedAt = redeemedAt
        self.status = status
    }
}

// MARK: - Leaderboard Entry (convenience, not a table)
struct LeaderboardEntry: Identifiable {
    let id: String
    let displayName: String
    let points: Int
    let rank: Int
    let avatarURL: String?
}
