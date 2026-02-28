import SwiftUI

struct HomeView: View {
    @ObservedObject var authService = AuthService.shared
    @StateObject private var triviaVM = TriviaViewModel()

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    headerSection

                    // Points Card
                    pointsCard

                    // Active Trivia Section
                    activeTriviaSection

                    // Upcoming Section
                    upcomingSection

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            triviaVM.loadActiveVideo()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundColor(GTTheme.textSecondary)
                Text(authService.currentUser?.displayName ?? "Yellow Jacket")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()

            // Profile badge
            ZStack {
                Circle()
                    .fill(GTTheme.techGold)
                    .frame(width: 48, height: 48)
                Text(String((authService.currentUser?.displayName ?? "U").prefix(1)))
                    .font(.title2.bold())
                    .foregroundColor(GTTheme.navyBlue)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Points Card
    private var pointsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("YOUR POINTS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(2)
                    .foregroundColor(GTTheme.techGold.opacity(0.8))

                Text("\(authService.currentUser?.points ?? 0)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(GTTheme.techGold)
            }

            Spacer()

            VStack(spacing: 4) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(GTTheme.techGold)
                Text("Rank #—")
                    .font(.caption2)
                    .foregroundColor(GTTheme.textSecondary)
            }
        }
        .gtCard()
    }

    // MARK: - Active Trivia
    private var activeTriviaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                Text("LIVE TRIVIA")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .tracking(2)
                    .foregroundColor(.red)
            }

            if let video = triviaVM.activeVideo {
                NavigationLink(destination: TriviaView(video: video, triviaVM: triviaVM)) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Video thumbnail placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(GTTheme.navyBlue)
                                .frame(height: 180)

                            VStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(GTTheme.techGold)
                                Text("Tap to Play")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }

                        Text(video.title)
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        Text(video.description)
                            .font(.subheadline)
                            .foregroundColor(GTTheme.textSecondary)
                            .lineLimit(2)

                        HStack {
                            Label("\(video.pointValue) pts", systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(GTTheme.techGold)

                            Spacer()

                            if triviaVM.hasAnswered {
                                Label("Answered", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(GTTheme.success)
                            } else {
                                Label("\(video.timeLimitSeconds)s Timer", systemImage: "timer")
                                    .font(.caption)
                                    .foregroundColor(GTTheme.textSecondary)
                            }
                        }
                    }
                    .gtCard()
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "tv.slash")
                        .font(.system(size: 36))
                        .foregroundColor(GTTheme.textSecondary)
                    Text("No live trivia right now")
                        .font(.subheadline)
                        .foregroundColor(GTTheme.textSecondary)
                    Text("Check back soon!")
                        .font(.caption)
                        .foregroundColor(GTTheme.textSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .gtCard()
            }
        }
    }

    // MARK: - Upcoming
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("UPCOMING")
                .font(.caption)
                .fontWeight(.heavy)
                .tracking(2)
                .foregroundColor(GTTheme.textSecondary)

            if triviaVM.upcomingVideos.isEmpty {
                Text("No upcoming trivia scheduled")
                    .font(.subheadline)
                    .foregroundColor(GTTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .gtCard()
            } else {
                ForEach(triviaVM.upcomingVideos) { video in
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(GTTheme.navyBlue)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "play.rectangle.fill")
                                    .foregroundColor(GTTheme.techGold)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(video.title)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)

                            Text(video.scheduledTime, style: .date)
                                .font(.caption)
                                .foregroundColor(GTTheme.textSecondary)
                        }

                        Spacer()

                        Text("\(video.pointValue) pts")
                            .font(.caption.bold())
                            .foregroundColor(GTTheme.techGold)
                    }
                    .gtCard()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
