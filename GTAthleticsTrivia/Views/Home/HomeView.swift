import SwiftUI

struct HomeView: View {
    @ObservedObject var authService = AuthService.shared
    @StateObject var triviaVM = TriviaViewModel()
    
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
                    
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            Task { try? await authService.loadProfile() }
            triviaVM.loadActiveVideo()
            triviaVM.startPolling()
        }
        .onDisappear {
            triviaVM.stopPolling()
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
                        // Live countdown indicator
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(triviaVM.timeRemaining <= 10 ? .red : GTTheme.techGold)
                            Text("\(triviaVM.timeRemaining)s remaining")
                                .font(.headline.bold().monospacedDigit())
                                .foregroundColor(triviaVM.timeRemaining <= 10 ? .red : GTTheme.techGold)
                            Spacer()
                            Text("LIVE")
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.red))
                                .foregroundColor(.white)
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
                                Label("Tap to Answer!", systemImage: "hand.tap.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(GTTheme.techGold)
                            }
                        }
                    }
                    .gtCard()
                }
            } else {
                VStack(spacing: 32) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 60))
                        .foregroundColor(GTTheme.techGold)
                    Text("Waiting for the next trivia question...")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("A new question will appear when the admin starts it.")
                        .font(.subheadline)
                        .foregroundColor(GTTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // #Preview {
    //     NavigationStack {
    //         HomeView()
    //     }
    // }
}
