import Foundation
import Supabase

// MARK: - Auth Service (Supabase)
@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false

    init() {
        Task { await restoreSession() }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, displayName: String, isAdmin: Bool = false) async throws {
        // Pass display_name in metadata so the DB trigger can use it
        let authResponse = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["display_name": .string(displayName)]
        )
        let userId = authResponse.user.id.uuidString

        // The DB trigger auto-creates a profile row.
        // Give it a moment, then load the profile.
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s

        // Try to load the trigger-created profile
        do {
            try await loadProfile()
        } catch {
            // Trigger may not have fired yet or user confirmed email required—
            // create a local user object so the UI works
            print("[AuthService] loadProfile after signup failed: \(error)")
            currentUser = AppUser(
                id: userId,
                email: email,
                displayName: displayName,
                points: 0,
                isAdmin: isAdmin
            )
            isAuthenticated = true
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
        try await loadProfile()
    }

    // MARK: - Sign Out
    func signOut() {
        Task {
            try? await supabase.auth.signOut()
            currentUser = nil
            isAuthenticated = false
        }
    }

    // MARK: - Update User
    func updateUser(_ user: AppUser) async throws {
        try await supabase.from("profiles")
            .update(user)
            .eq("id", value: user.id)
            .execute()

        if currentUser?.id == user.id {
            currentUser = user
        }
    }

    // MARK: - Get All Users (for leaderboard)
    func getAllUsers() async throws -> [AppUser] {
        let users: [AppUser] = try await supabase.from("profiles")
            .select()
            .order("points", ascending: false)
            .execute()
            .value
        return users
    }

    // MARK: - Restore Session
    private func restoreSession() async {
        do {
            _ = try await supabase.auth.session
            try await loadProfile()
        } catch {
            // No valid session
            isAuthenticated = false
        }
    }

    // MARK: - Load Profile
    func loadProfile() async throws {
        guard let userId = try? await supabase.auth.session.user.id else { return }

        let profile: AppUser = try await supabase.from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        currentUser = profile
        isAuthenticated = true
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
