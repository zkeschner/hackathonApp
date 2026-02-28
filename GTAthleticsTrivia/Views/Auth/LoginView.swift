import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            GTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    // Logo Area
                    VStack(spacing: 12) {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 60))
                            .foregroundColor(GTTheme.techGold)

                        Text("GT Athletics")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(GTTheme.techGold)

                        Text("TRIVIA")
                            .font(.system(size: 18, weight: .heavy))
                            .tracking(6)
                            .foregroundColor(GTTheme.white)
                    }

                    Spacer().frame(height: 20)

                    // Login Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(GTTheme.textSecondary)

                            TextField("", text: $viewModel.email)
                                .textFieldStyle(.plain)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(GTTheme.cardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(GTTheme.techGold.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(GTTheme.textSecondary)

                            SecureField("", text: $viewModel.password)
                                .textFieldStyle(.plain)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(GTTheme.cardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(GTTheme.techGold.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                        }

                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .font(.caption)
                                .foregroundColor(GTTheme.error)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: { viewModel.signIn() }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(GTTheme.navyBlue)
                            } else {
                                Text("Sign In")
                            }
                        }
                        .buttonStyle(GTButtonStyle())
                        .disabled(viewModel.isLoading)
                        .padding(.top, 8)

                        Button(action: { viewModel.showSignUp = true }) {
                            Text("Don't have an account? ")
                                .foregroundColor(GTTheme.textSecondary) +
                            Text("Sign Up")
                                .foregroundColor(GTTheme.techGold)
                                .bold()
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
            }
        }
        .sheet(isPresented: $viewModel.showSignUp) {
            SignUpView(viewModel: viewModel)
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
