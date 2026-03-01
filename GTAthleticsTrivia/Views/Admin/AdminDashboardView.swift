import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var adminVM = AdminViewModel()
    @State private var selectedTab: AdminTab = .videos

    enum AdminTab: String, CaseIterable {
        case videos = "Trivia"
        case predictions = "Predictions"
        case rewards = "Rewards"
        case stats = "Stats"
    }

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Admin Tab Picker
                Picker("", selection: $selectedTab) {
                    ForEach(AdminTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 12)

                switch selectedTab {
                case .videos:
                    AdminVideosView(adminVM: adminVM)
                case .predictions:
                    AdminPredictionsView(adminVM: adminVM)
                case .rewards:
                    AdminRewardsView(adminVM: adminVM)
                case .stats:
                    AdminStatsView()
                }
            }
        }
        .alert("Admin", isPresented: $adminVM.showMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(adminVM.message)
        }
    }
}

// MARK: - Admin Videos View
struct AdminVideosView: View {
    @ObservedObject var adminVM: AdminViewModel
    @State private var showUploadForm = false
    @State private var refreshTimer: Timer?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Upload Button
                Button(action: { showUploadForm.toggle() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Question")
                    }
                }
                .buttonStyle(GTButtonStyle())
                .padding(.top, 16)

                // Upload Form
                if showUploadForm {
                    uploadForm
                }

                // Existing Videos
                VStack(alignment: .leading, spacing: 12) {
                    Text("ALL VIDEOS")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .tracking(2)
                        .foregroundColor(GTTheme.textSecondary)

                    if adminVM.allVideos.isEmpty {
                        Text("No videos uploaded yet.")
                            .font(.subheadline)
                            .foregroundColor(GTTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(adminVM.allVideos) { video in
                            videoRow(video)
                        }
                    }
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            adminVM.refreshVideos()
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                Task { @MainActor in adminVM.refreshVideos() }
            }
        }
        .onDisappear {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }

    // MARK: - Upload Form
    private var uploadForm: some View {
        VStack(spacing: 14) {
            Text("New Trivia Question")
                .font(.headline)
                .foregroundColor(GTTheme.techGold)

            GTTextField(label: "Title", text: $adminVM.videoTitle, icon: "textformat")
            GTTextField(label: "Description (optional)", text: $adminVM.videoDescription, icon: "text.alignleft")

            Divider().background(GTTheme.techGold.opacity(0.3))

            GTTextField(label: "Question", text: $adminVM.questionText, icon: "questionmark.circle")

            ForEach(0..<4, id: \.self) { index in
                HStack(spacing: 8) {
                    Button(action: { adminVM.correctAnswerIndex = index }) {
                        Image(systemName: adminVM.correctAnswerIndex == index
                              ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(adminVM.correctAnswerIndex == index
                                             ? GTTheme.success : GTTheme.textSecondary)
                    }

                    GTTextField(
                        label: "Option \(["A", "B", "C", "D"][index])",
                        text: $adminVM.options[index],
                        icon: ""
                    )
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Points")
                        .font(.caption)
                        .foregroundColor(GTTheme.textSecondary)
                    Stepper("\(adminVM.pointValue) pts", value: $adminVM.pointValue, in: 5...100, step: 5)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading) {
                    Text("Time Limit")
                        .font(.caption)
                        .foregroundColor(GTTheme.textSecondary)
                    Stepper("\(adminVM.timeLimitSeconds)s", value: $adminVM.timeLimitSeconds, in: 10...120, step: 5)
                        .foregroundColor(.white)
                }
            }

            Button(action: {
                adminVM.uploadVideo()
                showUploadForm = false
            }) {
                Text("Add Question")
            }
            .buttonStyle(GTButtonStyle())
        }
        .gtCard()
    }

    // MARK: - Video Row
    private func videoRow(_ video: TriviaVideo) -> some View {
        let isLive = video.isActive && video.activatedAt != nil && Date().timeIntervalSince(video.activatedAt!) < Double(video.timeLimitSeconds)
        let remaining = isLive ? max(0, Int(Double(video.timeLimitSeconds) - Date().timeIntervalSince(video.activatedAt!))) : 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(video.title)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)

                        if isLive {
                            Text("LIVE \(remaining)s")
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.red))
                                .foregroundColor(.white)
                        }
                    }

                    if let created = video.createdAt {
                        Text(created, style: .date)
                            .font(.caption)
                            .foregroundColor(GTTheme.textSecondary)
                    }
                }

                Spacer()

                HStack(spacing: 12) {
                    if !isLive {
                        Button(action: { adminVM.activateVideo(video.id) }) {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(GTTheme.success)
                        }
                    }

                    Button(action: { adminVM.deleteVideo(video.id) }) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(GTTheme.error)
                    }
                }
            }

            Text("Q: \(video.questionText)")
                .font(.caption)
                .foregroundColor(GTTheme.textSecondary)
                .lineLimit(1)
        }
        .gtCard()
    }
}

// MARK: - Admin Predictions View
struct AdminPredictionsView: View {
    @ObservedObject var adminVM: AdminViewModel
    @State private var showCreateForm = false
    @State private var refreshTimer: Timer?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Create Button
                Button(action: { showCreateForm.toggle() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Prediction")
                    }
                }
                .buttonStyle(GTButtonStyle())
                .padding(.top, 16)

                // Create Form
                if showCreateForm {
                    createForm
                }

                // Active Predictions
                if !adminVM.activePredictions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ACTIVE PREDICTIONS")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .tracking(2)
                            .foregroundColor(GTTheme.textSecondary)

                        ForEach(adminVM.activePredictions) { prediction in
                            activePredictionRow(prediction)
                        }
                    }
                }

                // Closed Predictions
                if !adminVM.closedPredictions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CLOSED PREDICTIONS")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .tracking(2)
                            .foregroundColor(GTTheme.textSecondary)

                        ForEach(adminVM.closedPredictions) { prediction in
                            closedPredictionRow(prediction)
                        }
                    }
                }

                if adminVM.activePredictions.isEmpty && adminVM.closedPredictions.isEmpty {
                    Text("No predictions yet.")
                        .font(.subheadline)
                        .foregroundColor(GTTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            adminVM.refreshPredictions()
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                Task { @MainActor in adminVM.refreshPredictions() }
            }
        }
        .onDisappear {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }

    // MARK: - Create Form
    private var createForm: some View {
        VStack(spacing: 14) {
            Text("New Prediction")
                .font(.headline)
                .foregroundColor(GTTheme.techGold)

            GTTextField(label: "Question / Title", text: $adminVM.predictionTitle, icon: "questionmark.circle")
            GTTextField(label: "Description (optional)", text: $adminVM.predictionDescription, icon: "text.alignleft")

            VStack(alignment: .leading) {
                Text("Points for correct vote")
                    .font(.caption)
                    .foregroundColor(GTTheme.textSecondary)
                Stepper("\(adminVM.predictionPointValue) pts", value: $adminVM.predictionPointValue, in: 5...500, step: 5)
                    .foregroundColor(.white)
            }

            Button(action: {
                adminVM.createPrediction()
                showCreateForm = false
            }) {
                Text("Create Prediction")
            }
            .buttonStyle(GTButtonStyle())
        }
        .gtCard()
    }

    // MARK: - Active Prediction Row
    private func activePredictionRow(_ prediction: Prediction) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(prediction.title)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)

                        Text("LIVE")
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.green))
                            .foregroundColor(.white)
                    }

                    Text("\(prediction.pointValue) pts • Users vote YES or NO")
                        .font(.caption)
                        .foregroundColor(GTTheme.textSecondary)
                }

                Spacer()

                Button(action: { adminVM.deletePrediction(prediction.id) }) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(GTTheme.error)
                }
            }

            // Close Buttons
            HStack(spacing: 12) {
                Text("Close as:")
                    .font(.caption.bold())
                    .foregroundColor(GTTheme.textSecondary)

                Button(action: { adminVM.closePrediction(prediction.id, correctAnswer: true) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("YES wins")
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.green.opacity(0.2)))
                    .foregroundColor(.green)
                }

                Button(action: { adminVM.closePrediction(prediction.id, correctAnswer: false) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                        Text("NO wins")
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.red.opacity(0.2)))
                    .foregroundColor(.red)
                }
            }
        }
        .gtCard()
    }

    // MARK: - Closed Prediction Row
    private func closedPredictionRow(_ prediction: Prediction) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(prediction.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("CLOSED")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(GTTheme.textSecondary.opacity(0.3)))
                        .foregroundColor(GTTheme.textSecondary)

                    if let answer = prediction.correctAnswer {
                        Text("Answer: \(answer ? "YES" : "NO")")
                            .font(.caption.bold())
                            .foregroundColor(answer ? .green : .red)
                    }

                    Text("\(prediction.pointValue) pts")
                        .font(.caption)
                        .foregroundColor(GTTheme.textSecondary)
                }
            }

            Spacer()

            Button(action: { adminVM.deletePrediction(prediction.id) }) {
                Image(systemName: "trash.circle.fill")
                    .foregroundColor(GTTheme.error)
            }
        }
        .gtCard()
    }
}

// MARK: - Admin Rewards View
struct AdminRewardsView: View {
    @ObservedObject var adminVM: AdminViewModel
    @State private var showAddForm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button(action: { showAddForm.toggle() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Reward")
                    }
                }
                .buttonStyle(GTButtonStyle())
                .padding(.top, 16)

                if showAddForm {
                    addRewardForm
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("ALL REWARDS")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .tracking(2)
                        .foregroundColor(GTTheme.textSecondary)

                    ForEach(adminVM.allRewards) { reward in
                        rewardRow(reward)
                    }
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
    }

    private var addRewardForm: some View {
        VStack(spacing: 14) {
            Text("Add Reward")
                .font(.headline)
                .foregroundColor(GTTheme.techGold)

            GTTextField(label: "Name", text: $adminVM.rewardName, icon: "gift")
            GTTextField(label: "Description", text: $adminVM.rewardDescription, icon: "text.alignleft")

            VStack(alignment: .leading) {
                Text("Category")
                    .font(.caption)
                    .foregroundColor(GTTheme.textSecondary)
                Picker("", selection: $adminVM.rewardCategory) {
                    ForEach(RewardCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading) {
                Text("Point Cost")
                    .font(.caption)
                    .foregroundColor(GTTheme.textSecondary)
                TextField("Enter point cost", value: $adminVM.rewardPointCost, format: .number)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.1)))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading) {
                Text("Quantity (-1 = unlimited)")
                    .font(.caption)
                    .foregroundColor(GTTheme.textSecondary)
                Stepper("\(adminVM.rewardQuantity)", value: $adminVM.rewardQuantity, in: -1...1000)
                    .foregroundColor(.white)
            }

            Button(action: {
                adminVM.addReward()
                showAddForm = false
            }) {
                Text("Add Reward")
            }
            .buttonStyle(GTButtonStyle())
        }
        .gtCard()
    }

    private func rewardRow(_ reward: Reward) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(reward.category)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(GTTheme.techGold.opacity(0.2)))
                        .foregroundColor(GTTheme.techGold)

                    Text("\(reward.pointCost) pts")
                        .font(.caption)
                        .foregroundColor(GTTheme.textSecondary)

                    if reward.quantityAvailable >= 0 {
                        Text("Qty: \(reward.quantityAvailable)")
                            .font(.caption)
                            .foregroundColor(GTTheme.textSecondary)
                    }
                }
            }

            Spacer()

            Button(action: { adminVM.deleteReward(reward.id) }) {
                Image(systemName: "trash.circle.fill")
                    .foregroundColor(GTTheme.error)
            }
        }
        .gtCard()
    }
}

// MARK: - Admin Stats View
struct AdminStatsView: View {
    @ObservedObject var authService = AuthService.shared

    @State private var allUsers: [AppUser] = []

    func loadUsers() {
        Task {
            allUsers = (try? await authService.getAllUsers()) ?? []
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("OVERVIEW")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .tracking(2)
                    .foregroundColor(GTTheme.textSecondary)
                    .padding(.top, 16)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 14) {
                    statCard(title: "Total Users", value: "\(allUsers.count)", icon: "person.3.fill")
                    statCard(title: "Total Points", value: "\(allUsers.reduce(0) { $0 + $1.points })", icon: "star.fill")
                    statCard(title: "Videos", value: "\(TriviaService.shared.videos.count)", icon: "film")
                    statCard(title: "Rewards", value: "\(RewardsService.shared.rewards.count)", icon: "gift.fill")
                }
                .task { loadUsers() }

                VStack(alignment: .leading, spacing: 12) {
                    Text("ALL USERS")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .tracking(2)
                        .foregroundColor(GTTheme.textSecondary)

                    ForEach(allUsers) { user in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(user.displayName)
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                    if user.isAdmin {
                                        Text("ADMIN")
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 1)
                                            .background(Capsule().fill(GTTheme.techGold))
                                            .foregroundColor(GTTheme.navyBlue)
                                    }
                                }
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(GTTheme.textSecondary)
                            }
                            Spacer()
                            Text("\(user.points) pts")
                                .font(.caption.bold())
                                .foregroundColor(GTTheme.techGold)
                        }
                        .gtCard()
                    }
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(GTTheme.techGold)
            Text(value)
                .font(.title.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(GTTheme.textSecondary)
        }
        .gtCard()
    }
}

#Preview {
    NavigationStack {
        AdminDashboardView()
    }
}
