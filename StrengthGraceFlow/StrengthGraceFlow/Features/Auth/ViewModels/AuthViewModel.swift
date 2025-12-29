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
    @Published var authState: AuthState = .unauthenticated
    @Published var errorMessage: String?
    @Published var isLoading = false

    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    private let authService = AuthService.shared
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    #if DEBUG
    // Flag to prevent auth listener from overriding during developer onboarding reset
    private var isDeveloperOnboardingReset = false
    #endif

    init() {
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                #if DEBUG
                // Don't override state during developer onboarding reset
                guard self?.isDeveloperOnboardingReset != true else { return }
                #endif

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
            errorMessage = "We've sent you an email to reset your password."
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
            errorMessage = "Please enter your email address."
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Please choose a password."
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Your password needs at least 6 characters."
            return false
        }

        guard password == confirmPassword else {
            errorMessage = "Those passwords don't match. Please try again."
            return false
        }

        return true
    }

    private func validateSignInForm() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address."
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
        #if DEBUG
        isDeveloperOnboardingReset = false
        #endif
        authState = .authenticated
    }

    // MARK: - Developer Tools

    #if DEBUG
    func resetToOnboarding() {
        isDeveloperOnboardingReset = true
        authState = .onboarding
    }
    #endif

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
