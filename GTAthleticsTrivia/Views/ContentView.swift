import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()
    @ObservedObject var authService = AuthService.shared

    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                LoginView(viewModel: authVM)
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var selectedTab = 0
    
    var isAdmin: Bool {
        authService.currentUser?.isAdmin ?? false
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home
            NavigationStack {
                HomeView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: 6) {
                                Image(systemName: "sportscourt.fill")
                                    .foregroundColor(GTTheme.techGold)
                                Text("GT Trivia")
                                    .font(.headline.bold())
                                    .foregroundColor(GTTheme.techGold)
                            }
                        }
                    }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Leaderboard
            NavigationStack {
                LeaderboardView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(GTTheme.techGold)
                                Text("Rankings")
                                    .font(.headline.bold())
                                    .foregroundColor(GTTheme.techGold)
                            }
                        }
                    }
            }
            .tabItem {
                Image(systemName: "trophy.fill")
                Text("Rankings")
            }
            .tag(1)

            // Predictions
            NavigationStack {
                PredictionsView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Predict")
            }
            .tag(2)
            
            // Rewards
            NavigationStack {
                RewardsStoreView()
            }
            .tabItem {
                Image(systemName: "gift.fill")
                Text("Rewards")
            }
            .tag(3)
            
            // Admin (if admin)
            if isAdmin {
                NavigationStack {
                    AdminDashboardView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                HStack(spacing: 6) {
                                    Image(systemName: "shield.checkered")
                                        .foregroundColor(GTTheme.techGold)
                                    Text("Admin")
                                        .font(.headline.bold())
                                        .foregroundColor(GTTheme.techGold)
                                }
                            }
                        }
                }
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Admin")
                }
                .tag(4)
            }
            
            // Profile
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(5)
        }
        .tint(GTTheme.techGold)
        .onAppear {
            Task {
                _ = try? await supabase.functions.invoke("deactivation")
            }
        }
    }
    
    
    // MARK: - Profile View
    struct ProfileView: View {
        @ObservedObject var authService = AuthService.shared
        
        var body: some View {
            ZStack {
                GTTheme.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(GTTheme.techGold)
                                .frame(width: 80, height: 80)
                            Text(String((authService.currentUser?.displayName ?? "U").prefix(1)))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(GTTheme.navyBlue)
                        }
                        
                        Text(authService.currentUser?.displayName ?? "User")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text(authService.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(GTTheme.textSecondary)
                        
                        if authService.currentUser?.isAdmin == true {
                            Text("ADMIN")
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(GTTheme.techGold))
                                .foregroundColor(GTTheme.navyBlue)
                        }
                    }
                    .padding(.top, 24)
                    
                    // Stats
                    HStack(spacing: 0) {
                        profileStat(value: "\(authService.currentUser?.points ?? 0)", label: "Points")
                        Divider()
                            .frame(height: 40)
                            .background(GTTheme.textSecondary.opacity(0.3))
                        profileStat(value: "—", label: "Rank")
                        Divider()
                            .frame(height: 40)
                            .background(GTTheme.textSecondary.opacity(0.3))
                        profileStat(value: "—", label: "Weeks")
                    }
                    .gtCard()
                    
                    Spacer()
                    
                    // Sign Out
                    Button(action: {
                        authService.signOut()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                    .buttonStyle(GTButtonStyle(isSecondary: true))
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.headline.bold())
                        .foregroundColor(GTTheme.techGold)
                }
            }
            .onAppear {
                Task { try? await authService.loadProfile() }
            }
        }
        
        private func profileStat(value: String, label: String) -> some View {
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(GTTheme.techGold)
                Text(label)
                    .font(.caption)
                    .foregroundColor(GTTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    #Preview {
        ContentView()
    }
}
