import SwiftUI
import AVKit

struct TriviaView: View {
    let video: TriviaVideo
    @ObservedObject var triviaVM: TriviaViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showQuestion = false
    @State private var animateOptions = false

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Video Player Area
                    videoPlayerSection

                    if triviaVM.hasAnswered {
                        resultSection
                    } else if showQuestion {
                        questionSection
                    } else {
                        readySection
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
        .onAppear {
            if triviaVM.hasAnswered {
                showQuestion = true
            }
        }
    }

    // MARK: - Video Player
    private var videoPlayerSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(GTTheme.navyBlue)
                .frame(height: 220)

            VStack(spacing: 12) {
                Image(systemName: "film")
                    .font(.system(size: 48))
                    .foregroundColor(GTTheme.techGold)

                Text(video.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Video plays here")
                    .font(.caption)
                    .foregroundColor(GTTheme.textSecondary)

                // In production, replace with:
                // VideoPlayer(player: AVPlayer(url: URL(string: video.videoURL)!))
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Ready Button
    private var readySection: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(GTTheme.techGold)

            Text("Ready for the question?")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Watch the video above, then tap below to see the trivia question. You'll have \(video.question.timeLimitSeconds) seconds to answer!")
                .font(.subheadline)
                .foregroundColor(GTTheme.textSecondary)
                .multilineTextAlignment(.center)

            Text("\(video.question.pointValue) points available")
                .font(.caption.bold())
                .foregroundColor(GTTheme.techGold)

            Button(action: {
                withAnimation(.spring()) {
                    showQuestion = true
                }
                triviaVM.startTimer()
            }) {
                Text("Show Question")
            }
            .buttonStyle(GTButtonStyle())
        }
        .gtCard()
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
            Text(video.question.questionText)
                .font(.title3.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Options
            VStack(spacing: 12) {
                ForEach(Array(video.question.options.enumerated()), id: \.offset) { index, option in
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
                Text(video.question.questionText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                ForEach(Array(video.question.options.enumerated()), id: \.offset) { index, option in
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

                        if index == video.question.correctAnswerIndex {
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
        if index == video.question.correctAnswerIndex {
            return GTTheme.success
        } else if index == triviaVM.selectedAnswer {
            return GTTheme.error
        }
        return GTTheme.techGold
    }

    private func answerBackground(_ index: Int) -> Color {
        if index == video.question.correctAnswerIndex {
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
                videoURL: "",
                scheduledTime: Date(),
                question: TriviaQuestion(
                    questionText: "What color is Tech Gold?",
                    options: ["Blue", "Gold", "Red", "Green"],
                    correctAnswerIndex: 1
                ),
                uploadedBy: "admin"
            ),
            triviaVM: TriviaViewModel()
        )
    }
}
