//
//  AuthService.swift
//  app
//

import AuthenticationServices
import Combine
import SwiftUI

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?

    struct User {
        let id: String
        let name: String
        let email: String
        let profileImageUrl: String?
        let authProvider: AuthProvider
    }

    enum AuthProvider: String {
        case apple, google
    }

    init() {
        self.isAuthenticated = false
    }

    func signInWithApple(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentUser = User(
                id: "apple_user_123",
                name: "Apple User",
                email: "user@apple.com",
                profileImageUrl: nil,
                authProvider: .apple
            )
            self.isAuthenticated = true
            completion?()
        }
    }

    func signInWithGoogle(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentUser = User(
                id: "google_user_456",
                name: "Google User",
                email: "user@gmail.com",
                profileImageUrl: "https://example.com/profile.jpg",
                authProvider: .google
            )
            self.isAuthenticated = true
            completion?()
        }
    }

    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
}
