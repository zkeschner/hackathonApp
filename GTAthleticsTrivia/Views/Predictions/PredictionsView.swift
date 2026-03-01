import SwiftUI

struct PredictionsView: View {
    @StateObject private var predictionVM = PredictionViewModel()
    @ObservedObject var authService = AuthService.shared

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Multiplier Banner
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Points Multiplier: \(PointsMultiplier.display)")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.15))
                    )
                    .padding(.top, 16)

                    // Active Predictions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            Text("LIVE PREDICTIONS")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .tracking(2)
                                .foregroundColor(.green)
                        }

                        if predictionVM.activePredictions.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 48))
                                    .foregroundColor(GTTheme.textSecondary)
                                Text("No active predictions right now")
                                    .font(.subheadline)
                                    .foregroundColor(GTTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        } else {
                            ForEach(predictionVM.activePredictions) { prediction in
                                predictionCard(prediction)
                            }
                        }
                    }

                    // Closed Predictions
                    if !predictionVM.closedPredictions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CLOSED")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .tracking(2)
                                .foregroundColor(GTTheme.textSecondary)

                            ForEach(predictionVM.closedPredictions) { prediction in
                                closedPredictionCard(prediction)
                            }
                        }
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(GTTheme.techGold)
                    Text("Predictions")
                        .font(.headline.bold())
                        .foregroundColor(GTTheme.techGold)
                }
            }
        }
        .onAppear {
            predictionVM.load()
            predictionVM.startPolling()
        }
        .onDisappear {
            predictionVM.stopPolling()
        }
        .alert("Predictions", isPresented: $predictionVM.showResult) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(predictionVM.resultMessage)
        }
    }

    // MARK: - Active Prediction Card
    private func predictionCard(_ prediction: Prediction) -> some View {
        let voted = predictionVM.hasVoted(predictionId: prediction.id)
        let userVote = predictionVM.getUserVote(predictionId: prediction.id)

        return VStack(alignment: .leading, spacing: 14) {
            // Title
            Text(prediction.title)
                .font(.title3.bold())
                .foregroundColor(.white)

            if !prediction.description.isEmpty {
                Text(prediction.description)
                    .font(.subheadline)
                    .foregroundColor(GTTheme.textSecondary)
            }

            HStack {
                Label("\(prediction.pointValue) pts", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(GTTheme.techGold)
                Spacer()
                Text("LIVE")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.green))
                    .foregroundColor(.white)
            }

            if voted, let userVote = userVote {
                // Already voted
                HStack(spacing: 12) {
                    voteIndicator(label: "YES", isSelected: userVote.vote == true, color: GTTheme.success)
                    voteIndicator(label: "NO", isSelected: userVote.vote == false, color: GTTheme.error)
                }

                Text("You voted \(userVote.vote ? "YES" : "NO") — waiting for results...")
                    .font(.caption)
                    .foregroundColor(GTTheme.textSecondary)
            } else {
                // Vote buttons
                HStack(spacing: 12) {
                    Button(action: { predictionVM.submitVote(predictionId: prediction.id, vote: true) }) {
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                            Text("YES")
                                .font(.headline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(GTTheme.success))
                        .foregroundColor(.white)
                    }

                    Button(action: { predictionVM.submitVote(predictionId: prediction.id, vote: false) }) {
                        HStack {
                            Image(systemName: "hand.thumbsdown.fill")
                            Text("NO")
                                .font(.headline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(GTTheme.error))
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .gtCard()
    }

    // MARK: - Vote Indicator
    private func voteIndicator(label: String, isSelected: Bool, color: Color) -> some View {
        HStack {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
            }
            Text(label)
                .font(.headline.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? color.opacity(0.3) : GTTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
        )
        .foregroundColor(isSelected ? color : GTTheme.textSecondary)
    }

    // MARK: - Closed Prediction Card
    private func closedPredictionCard(_ prediction: Prediction) -> some View {
        let userVote = predictionVM.getUserVote(predictionId: prediction.id)
        let correctAnswer = prediction.correctAnswer
        let userWon = userVote != nil && correctAnswer != nil && userVote!.vote == correctAnswer!

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(prediction.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)

                Spacer()

                if let correct = correctAnswer {
                    Text("Answer: \(correct ? "YES" : "NO")")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(correct ? GTTheme.success.opacity(0.3) : GTTheme.error.opacity(0.3)))
                        .foregroundColor(correct ? GTTheme.success : GTTheme.error)
                }
            }

            if let userVote = userVote {
                HStack(spacing: 4) {
                    Image(systemName: userWon ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(userWon ? GTTheme.success : GTTheme.error)
                    Text(userWon ? "+\(Int(Double(prediction.pointValue) * PointsMultiplier.current)) pts" : "0 pts")
                        .font(.caption.bold())
                        .foregroundColor(userWon ? GTTheme.success : GTTheme.error)
                    Text("• You voted \(userVote.vote ? "YES" : "NO")")
                        .font(.caption)
                        .foregroundColor(GTTheme.textSecondary)
                }
            } else {
                Text("You didn't vote")
                    .font(.caption)
                    .foregroundColor(GTTheme.textSecondary)
            }
        }
        .gtCard()
    }
}

#Preview {
    NavigationStack {
        PredictionsView()
    }
}
