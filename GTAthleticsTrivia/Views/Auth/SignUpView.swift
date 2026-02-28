import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(GTTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 16)

                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(GTTheme.techGold)

                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Join GT Athletics Trivia")
                            .font(.subheadline)
                            .foregroundColor(GTTheme.textSecondary)
                    }

                    VStack(spacing: 16) {
                        GTTextField(label: "Display Name", text: $viewModel.displayName, icon: "person.fill")
                        GTTextField(label: "Email", text: $viewModel.email, icon: "envelope.fill", keyboard: .emailAddress)
                        GTSecureField(label: "Password", text: $viewModel.password, icon: "lock.fill")
                        GTSecureField(label: "Confirm Password", text: $viewModel.confirmPassword, icon: "lock.shield.fill")

                        Toggle(isOn: $viewModel.isAdmin) {
                            HStack(spacing: 8) {
                                Image(systemName: "shield.checkered")
                                    .foregroundColor(GTTheme.techGold)
                                Text("Admin Account")
                                    .foregroundColor(.white)
                            }
                        }
                        .tint(GTTheme.techGold)
                        .padding(.vertical, 4)

                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .font(.caption)
                                .foregroundColor(GTTheme.error)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: {
                            viewModel.signUp()
                            if viewModel.errorMessage.isEmpty {
                                dismiss()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView().tint(GTTheme.navyBlue)
                            } else {
                                Text("Create Account")
                            }
                        }
                        .buttonStyle(GTButtonStyle())
                        .disabled(viewModel.isLoading)
                        .padding(.top, 8)
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: - Reusable GT Text Fields
struct GTTextField: View {
    let label: String
    @Binding var text: String
    var icon: String = ""
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(GTTheme.textSecondary)

            HStack(spacing: 10) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .foregroundColor(GTTheme.techGold.opacity(0.7))
                        .frame(width: 20)
                }
                TextField("", text: $text)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .keyboardType(keyboard)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(GTTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(GTTheme.techGold.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct GTSecureField: View {
    let label: String
    @Binding var text: String
    var icon: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(GTTheme.textSecondary)

            HStack(spacing: 10) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .foregroundColor(GTTheme.techGold.opacity(0.7))
                        .frame(width: 20)
                }
                SecureField("", text: $text)
                    .foregroundColor(.white)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(GTTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(GTTheme.techGold.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    SignUpView(viewModel: AuthViewModel())
}
