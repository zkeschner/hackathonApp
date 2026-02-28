import Foundation

// MARK: - Auth Service (Local mock — swap for Firebase/Supabase)
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false

    private let usersKey = "gt_athletics_users"
    private let currentUserKey = "gt_athletics_current_user"

    init() {
        loadCurrentUser()
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, displayName: String, isAdmin: Bool = false) throws {
        var users = loadAllUsers()

        if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            throw AuthError.emailAlreadyInUse
        }

        let newUser = AppUser(
            email: email,
            displayName: displayName,
            points: 0,
            isAdmin: isAdmin
        )

        users.append(newUser)
        saveAllUsers(users)
        saveCredentials(email: email, password: password)

        currentUser = newUser
        isAuthenticated = true
        saveCurrentUser(newUser)
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) throws {
        let users = loadAllUsers()

        guard let user = users.first(where: { $0.email.lowercased() == email.lowercased() }) else {
            throw AuthError.userNotFound
        }

        let storedPassword = UserDefaults.standard.string(forKey: "pwd_\(email.lowercased())")
        guard storedPassword == password else {
            throw AuthError.wrongPassword
        }

        currentUser = user
        isAuthenticated = true
        saveCurrentUser(user)
    }

    // MARK: - Sign Out
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }

    // MARK: - Update User
    func updateUser(_ user: AppUser) {
        var users = loadAllUsers()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveAllUsers(users)
        }
        if currentUser?.id == user.id {
            currentUser = user
            saveCurrentUser(user)
        }
    }

    // MARK: - Get All Users (for leaderboard)
    func getAllUsers() -> [AppUser] {
        return loadAllUsers()
    }

    // MARK: - Private Helpers
    private func loadCurrentUser() {
        guard let data = UserDefaults.standard.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else { return }

        // Refresh from stored users to get latest points
        let users = loadAllUsers()
        if let freshUser = users.first(where: { $0.id == user.id }) {
            currentUser = freshUser
        } else {
            currentUser = user
        }
        isAuthenticated = true
    }

    private func saveCurrentUser(_ user: AppUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: currentUserKey)
        }
    }

    private func loadAllUsers() -> [AppUser] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([AppUser].self, from: data) else { return [] }
        return users
    }

    private func saveAllUsers(_ users: [AppUser]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }

    private func saveCredentials(email: String, password: String) {
        UserDefaults.standard.set(password, forKey: "pwd_\(email.lowercased())")
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse: return "An account with this email already exists."
        case .userNotFound: return "No account found with this email."
        case .wrongPassword: return "Incorrect password."
        case .invalidEmail: return "Please enter a valid email."
        }
    }
}
