//
//  AuthView.swift
//  app
//

import AuthenticationServices
import SwiftUI

struct AuthView: View {
    @ObservedObject var authService: AuthService
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "sensor.tag.radiowaves.forward.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)

                        Text("Rituo")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Sign in to sync your NFC workspace")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 50)

                    Spacer()

                    VStack(spacing: 20) {
                        Button {
                            isLoading = true
                            authService.signInWithApple {
                                isLoading = false
                            }
                        } label: {
                            AuthButton(
                                icon: "applelogo",
                                title: "Continue with Apple",
                                backgroundColor: .black,
                                foregroundColor: .white
                            )
                        }
                        .disabled(isLoading)

                        Button {
                            isLoading = true
                            authService.signInWithGoogle {
                                isLoading = false
                            }
                        } label: {
                            AuthButton(
                                icon: "g.circle.fill",
                                title: "Continue with Google",
                                backgroundColor: .white,
                                foregroundColor: .black
                            )
                        }
                        .disabled(isLoading)

                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))

                            Text("or")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)

                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.vertical, 20)

                        NavigationLink(destination: EmailLoginView()) {
                            Text("Continue with Email")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 30)

                    VStack(spacing: 10) {
                        Text("By continuing, you agree to our")
                            .foregroundColor(.secondary)
                            .font(.caption)

                        HStack(spacing: 5) {
                            Button("Terms of Service") {}
                                .font(.caption)
                                .foregroundColor(.blue)

                            Text("and")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button("Privacy Policy") {}
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 30)
                }

                if isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Signing in...")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct AuthButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            Spacer()
            Text(title)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct EmailLoginView: View {
    var body: some View {
        Text("Email Login")
            .navigationTitle("Email Login")
    }
}
