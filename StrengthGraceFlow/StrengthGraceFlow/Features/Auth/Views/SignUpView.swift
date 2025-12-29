//
//  SignUpView.swift
//  StrengthGraceFlow
//
//  Sign up form
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password, confirmPassword
    }

    var body: some View {
        ZStack {
            Color.sgfBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: SGFSpacing.xl) {
                    // Header
                    VStack(spacing: SGFSpacing.sm) {
                        Text("Create Account")
                            .font(.sgfTitle)
                            .foregroundColor(.sgfTextPrimary)

                        Text("Movement in harmony with your body's rhythm")
                            .font(.sgfBody)
                            .foregroundColor(.sgfTextSecondary)
                    }
                    .padding(.top, SGFSpacing.xl)

                    // Form
                    VStack(spacing: SGFSpacing.md) {
                        // Email
                        VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                            Text("Email")
                                .font(.sgfSubheadline)
                                .foregroundColor(.sgfTextSecondary)

                            TextField("your@email.com", text: $authViewModel.email)
                                .textFieldStyle(SGFTextFieldStyle())
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }

                        // Password
                        VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                            Text("Password")
                                .font(.sgfSubheadline)
                                .foregroundColor(.sgfTextSecondary)

                            SecureField("At least 6 characters", text: $authViewModel.password)
                                .textFieldStyle(SGFTextFieldStyle())
                                .textContentType(.newPassword)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .confirmPassword
                                }
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                            Text("Confirm Password")
                                .font(.sgfSubheadline)
                                .foregroundColor(.sgfTextSecondary)

                            SecureField("Re-enter your password", text: $authViewModel.confirmPassword)
                                .textFieldStyle(SGFTextFieldStyle())
                                .textContentType(.newPassword)
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.go)
                                .onSubmit {
                                    Task { await authViewModel.signUp() }
                                }
                        }
                    }
                    .padding(.horizontal, SGFSpacing.lg)

                    // Error message
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.sgfSubheadline)
                            .foregroundColor(.sgfError)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SGFSpacing.lg)
                    }

                    // Sign up button
                    Button {
                        Task { await authViewModel.signUp() }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
                        }
                    }
                    .buttonStyle(SGFPrimaryButtonStyle(isDisabled: authViewModel.isLoading))
                    .disabled(authViewModel.isLoading)
                    .padding(.horizontal, SGFSpacing.lg)

                    // Terms
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                        .font(.sgfCaption)
                        .foregroundColor(.sgfTextTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SGFSpacing.xl)

                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.sgfTextPrimary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
