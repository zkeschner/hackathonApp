import SwiftUI
import AVKit

struct TriviaView: View {
    let video: TriviaVideo
    @ObservedObject var triviaVM: TriviaViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Video Player Area
                    videoPlayerSection

                    if triviaVM.hasAnswered {
                        resultSection
                    } else if triviaVM.timeRemaining > 0 {
                        questionSection
                    } else {
                        // Time expired
                        VStack(spacing: 16) {
                            Image(systemName: "clock.badge.xmark")
                                .font(.system(size: 60))
                                .foregroundColor(GTTheme.error)
                            Text("Time's Up!")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Button(action: { dismiss() }) {
                                Text("Back to Home")
                            }
                            .buttonStyle(GTButtonStyle(isSecondary: true))
                        }
                        .gtCard()
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(video.title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Video Player
    private var videoPlayerSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(GTTheme.navyBlue)
                .frame(height: 220)

            if let url = URL(string: video.videoURL) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "film")
                        .font(.system(size: 48))
                        .foregroundColor(GTTheme.techGold)
                    Text(video.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Video unavailable")
                        .font(.caption)
                        .foregroundColor(GTTheme.textSecondary)
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Question Section
    private var questionSection: some View {
        VStack(spacing: 20) {
            // Timer
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(triviaVM.timeRemaining <= 10 ? .red : GTTheme.techGold)
                Text("\(triviaVM.timeRemaining)s")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundColor(triviaVM.timeRemaining <= 10 ? .red : GTTheme.techGold)
            }
            .animation(.easeInOut, value: triviaVM.timeRemaining)

            // Question
            Text(video.questionText)
                .font(.title3.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Options
            VStack(spacing: 12) {
                ForEach(Array(video.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        triviaVM.submitAnswer(selectedIndex: index)
                    }) {
                        HStack {
                            Text(optionLetter(index))
                                .font(.headline.bold())
                                .foregroundColor(GTTheme.navyBlue)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(GTTheme.techGold))

                            Text(option)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)

                            Spacer()
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(GTTheme.cardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(GTTheme.techGold.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(triviaVM.hasAnswered)
                }
            }
        }
        .gtCard()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Result Section
    private var resultSection: some View {
        VStack(spacing: 20) {
            Image(systemName: triviaVM.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(triviaVM.isCorrect ? GTTheme.success : GTTheme.error)

            Text(triviaVM.isCorrect ? "Correct!" : "Wrong!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(triviaVM.isCorrect ? GTTheme.success : GTTheme.error)

            if triviaVM.isCorrect {
                Text("+\(triviaVM.pointsEarned) points!")
                    .font(.title2)
                    .foregroundColor(GTTheme.techGold)
            }

            // Show correct answer
            VStack(spacing: 12) {
                Text(video.questionText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                ForEach(Array(video.options.enumerated()), id: \.offset) { index, option in
                    HStack {
                        Text(optionLetter(index))
                            .font(.caption.bold())
                            .foregroundColor(GTTheme.navyBlue)
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(optionColor(index)))

                        Text(option)
                            .font(.subheadline)
                            .foregroundColor(.white)

                        Spacer()

                        if index == video.correctAnswerIndex {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(GTTheme.success)
                        } else if index == triviaVM.selectedAnswer {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(GTTheme.error)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(answerBackground(index))
                    )
                }
            }

            Button(action: { dismiss() }) {
                Text("Back to Home")
            }
            .buttonStyle(GTButtonStyle(isSecondary: true))
        }
        .gtCard()
    }

    // MARK: - Helpers
    private func optionLetter(_ index: Int) -> String {
        ["A", "B", "C", "D", "E", "F"][safe: index] ?? "?"
    }

    private func optionColor(_ index: Int) -> Color {
        if index == video.correctAnswerIndex {
            return GTTheme.success
        } else if index == triviaVM.selectedAnswer {
            return GTTheme.error
        }
        return GTTheme.techGold
    }

    private func answerBackground(_ index: Int) -> Color {
        if index == video.correctAnswerIndex {
            return GTTheme.success.opacity(0.15)
        } else if index == triviaVM.selectedAnswer {
            return GTTheme.error.opacity(0.15)
        }
        return GTTheme.cardBackground
    }
}

// Safe Array Access
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        TriviaView(
            video: TriviaVideo(
                title: "Sample Trivia",
                description: "",
                videoURL: "",
                thumbnailURL: nil,
                scheduledTime: Date(),
                isActive: false,
                questionText: "What color is Tech Gold?",
                options: ["Blue", "Gold", "Red", "Green"],
                correctAnswerIndex: 1,
                pointValue: 10,
                timeLimitSeconds: 30,
                uploadedBy: "admin",
                createdAt: nil,
                activatedAt: nil
            ),
            triviaVM: TriviaViewModel()
        )
    }
}
