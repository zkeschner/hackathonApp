import Foundation
import SwiftUI

// MARK: - Trivia ViewModel
class TriviaViewModel: ObservableObject {
    @Published var activeVideo: TriviaVideo?
    @Published var selectedAnswer: Int? = nil
    @Published var hasAnswered = false
    @Published var isCorrect = false
    @Published var pointsEarned = 0
    @Published var timeRemaining: Int = 30
    @Published var isTimerActive = false
    @Published var showResult = false
    @Published var countdownToLive: String = ""

    private let triviaService = TriviaService.shared
    private let authService = AuthService.shared
    private var timer: Timer?

    var upcomingVideos: [TriviaVideo] {
        triviaService.getUpcomingVideos()
    }

    var pastVideos: [TriviaVideo] {
        triviaService.getPastVideos()
    }

    func loadActiveVideo() {
        activeVideo = triviaService.getActiveVideo()
        if let video = activeVideo, let user = authService.currentUser {
            hasAnswered = triviaService.hasAnswered(userId: user.id, videoId: video.id)
        }
    }

    func startTimer() {
        guard let video = activeVideo else { return }
        timeRemaining = video.question.timeLimitSeconds
        isTimerActive = true

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.isTimerActive = false
                if !self.hasAnswered {
                    self.submitAnswer(selectedIndex: -1) // Time expired
                }
            }
        }
    }

    func submitAnswer(selectedIndex: Int) {
        guard let video = activeVideo, let user = authService.currentUser else { return }

        selectedAnswer = selectedIndex
        timer?.invalidate()
        isTimerActive = false

        let result = triviaService.submitAnswer(
            userId: user.id,
            videoId: video.id,
            questionId: video.question.id,
            selectedIndex: selectedIndex
        )

        isCorrect = result.correct
        pointsEarned = result.points
        hasAnswered = true
        showResult = true

        // Update user points
        if result.points > 0 {
            var updatedUser = user
            updatedUser.points += result.points
            authService.updateUser(updatedUser)
        }
    }

    func resetForNewVideo() {
        selectedAnswer = nil
        hasAnswered = false
        isCorrect = false
        pointsEarned = 0
        showResult = false
        timer?.invalidate()
        isTimerActive = false
    }

    func updateCountdown() {
        guard let video = activeVideo else {
            countdownToLive = ""
            return
        }

        let diff = video.scheduledTime.timeIntervalSince(Date())
        if diff <= 0 {
            countdownToLive = "LIVE NOW"
        } else {
            let hours = Int(diff) / 3600
            let minutes = (Int(diff) % 3600) / 60
            let seconds = Int(diff) % 60
            if hours > 24 {
                let days = hours / 24
                countdownToLive = "\(days)d \(hours % 24)h"
            } else if hours > 0 {
                countdownToLive = "\(hours)h \(minutes)m"
            } else {
                countdownToLive = "\(minutes)m \(seconds)s"
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
