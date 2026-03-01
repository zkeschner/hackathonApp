import Foundation
import SwiftUI

// MARK: - Auth ViewModel
@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    @Published var isAdmin = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var showSignUp = false

    private let authService = AuthService.shared

    var isAuthenticated: Bool {
        authService.isAuthenticated
    }

    var currentUser: AppUser? {
        authService.currentUser
    }

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authService.signIn(email: email, password: password)
                clearFields()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords don't match."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authService.signUp(email: email, password: password, displayName: displayName, isAdmin: isAdmin)
                clearFields()
            } catch {
                print("[SignUp Error] \(error)")
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func signOut() {
        authService.signOut()
    }

    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        errorMessage = ""
    }
}
