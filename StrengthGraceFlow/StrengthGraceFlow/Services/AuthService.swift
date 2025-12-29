//
//  AuthService.swift
//  StrengthGraceFlow
//
//  Firebase Authentication service wrapper
//

import Foundation
import FirebaseAuth

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case wrongPassword
    case userNotFound
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please check your email address."
        case .weakPassword:
            return "Your password needs at least 6 characters."
        case .emailAlreadyInUse:
            return "This email is already connected to an account."
        case .wrongPassword:
            return "That password doesn't look quite right. Please try again."
        case .userNotFound:
            return "We couldn't find an account with this email."
        case .networkError:
            return "We're having trouble connecting. Please check your connection and try again."
        case .unknown(let message):
            return message
        }
    }
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAuthenticated = user != nil
        }
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.currentUser = result.user
            self.isAuthenticated = true
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.currentUser = result.user
            self.isAuthenticated = true
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Get ID Token

    func getIdToken() async throws -> String {
        guard let user = currentUser else {
            throw AuthError.userNotFound
        }
        return try await user.getIDToken()
    }

    // MARK: - Error Mapping

    private func mapFirebaseError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error.localizedDescription)
        }

        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .wrongPassword, .invalidCredential:
            return .wrongPassword
        case .userNotFound:
            return .userNotFound
        case .networkError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
