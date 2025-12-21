//
//  AuthViewModel.swift
//  StrengthGraceFlow
//
//  View model for authentication state and actions
//

import Foundation
import FirebaseAuth

enum AuthState {
    case loading
    case unauthenticated
    case authenticated
    case onboarding
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var errorMessage: String?
    @Published var isLoading = false

    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    private let authService = AuthService.shared
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if user != nil {
                    // Check if user has completed onboarding
                    // For now, assume authenticated users have completed onboarding
                    // This will be updated when we implement user profile fetching
                    self?.authState = .authenticated
                } else {
                    self?.authState = .unauthenticated
                }
            }
        }
    }

    // MARK: - Sign Up

    func signUp() async {
        guard validateSignUpForm() else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signUp(email: email, password: password)
            authState = .onboarding
            clearForm()
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign In

    func signIn() async {
        guard validateSignInForm() else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signIn(email: email, password: password)
            clearForm()
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try authService.signOut()
            authState = .unauthenticated
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Password Reset

    func resetPassword() async {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.resetPassword(email: email)
            errorMessage = "Password reset email sent. Check your inbox."
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Validation

    private func validateSignUpForm() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email."
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter a password."
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        return true
    }

    private func validateSignInForm() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email."
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return false
        }

        return true
    }

    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
    }

    // MARK: - Onboarding Complete

    func completeOnboarding() {
        authState = .authenticated
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
