//
//  SignInView.swift
//  StrengthGraceFlow
//
//  Sign in form
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        ZStack {
            Color.sgfBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: SGFSpacing.xl) {
                    // Header
                    VStack(spacing: SGFSpacing.sm) {
                        Text("Welcome Back")
                            .font(.sgfTitle)
                            .foregroundColor(.sgfTextPrimary)

                        Text("Sign in to continue your journey")
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

                            SecureField("Enter your password", text: $authViewModel.password)
                                .textFieldStyle(SGFTextFieldStyle())
                                .textContentType(.password)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.go)
                                .onSubmit {
                                    Task { await authViewModel.signIn() }
                                }
                        }

                        // Forgot password
                        HStack {
                            Spacer()
                            Button("Forgot password?") {
                                Task { await authViewModel.resetPassword() }
                            }
                            .font(.sgfSubheadline)
                            .foregroundColor(.sgfPrimary)
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

                    // Sign in button
                    Button {
                        Task { await authViewModel.signIn() }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                        }
                    }
                    .buttonStyle(SGFPrimaryButtonStyle(isDisabled: authViewModel.isLoading))
                    .disabled(authViewModel.isLoading)
                    .padding(.horizontal, SGFSpacing.lg)

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
        SignInView()
            .environmentObject(AuthViewModel())
    }
}
