import Foundation
import SwiftUI

// MARK: - Trivia ViewModel
@MainActor
class TriviaViewModel: ObservableObject {
    @Published var activeVideo: TriviaVideo?
    @Published var selectedAnswer: Int? = nil
    @Published var hasAnswered = false
    @Published var isCorrect = false
    @Published var pointsEarned = 0
    @Published var timeRemaining: Int = 30
    @Published var isTimerActive = false
    @Published var showResult = false

    private let triviaService = TriviaService.shared
    private let authService = AuthService.shared
    private var timer: Timer?
    private var pollTimer: Timer?

    var pastVideos: [TriviaVideo] {
        triviaService.getPastVideos()
    }

    // MARK: - Load & Auto-Start Timer from activated_at
    func loadActiveVideo() {
        Task {
            await triviaService.fetchVideos()
            let maybeActive = triviaService.getActiveVideo()
            if let video = maybeActive, let activatedAt = video.activatedAt {
                let elapsed = Date().timeIntervalSince(activatedAt)
                let remaining = Double(video.timeLimitSeconds) - elapsed
                if remaining > 0 {
                    activeVideo = video
                    timeRemaining = Int(remaining)
                    if let user = authService.currentUser {
                        hasAnswered = await triviaService.hasAnswered(userId: user.id, videoId: video.id)
                    }
                    // Auto-start the countdown timer
                    if !hasAnswered {
                        startCountdown()
                    }
                } else {
                    // Time expired — no longer active for this user
                    activeVideo = nil
                }
            } else {
                activeVideo = nil
            }
        }
    }

    // MARK: - Countdown Timer (auto-started from activated_at)
    private func startCountdown() {
        guard activeVideo != nil else { return }
        isTimerActive = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                    self.isTimerActive = false
                    if !self.hasAnswered {
                        self.submitAnswer(selectedIndex: -1)
                    }
                }
            }
        }
    }

    // MARK: - Polling (detect activation/deactivation changes)
    func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.loadActiveVideo()
            }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    // MARK: - Submit Answer
    func submitAnswer(selectedIndex: Int) {
        guard let video = activeVideo, let user = authService.currentUser else { return }

        selectedAnswer = selectedIndex
        timer?.invalidate()
        isTimerActive = false

        Task {
            do {
                let result = try await triviaService.submitAnswer(
                    userId: user.id,
                    videoId: video.id,
                    selectedIndex: selectedIndex
                )

                isCorrect = result.correct
                pointsEarned = result.points
                hasAnswered = true
                showResult = true

                if result.points > 0 {
                    var updatedUser = user
                    updatedUser.points += result.points
                    authService.currentUser = updatedUser
                }
            } catch {
                print("Error submitting answer: \(error)")
            }
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

    deinit {
        timer?.invalidate()
        pollTimer?.invalidate()
    }
}
