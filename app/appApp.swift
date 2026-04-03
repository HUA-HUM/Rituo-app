//
//  appApp.swift
//  app
//
//  Created by Jesus Lopez on 11/3/26.
//

import SwiftUI

@main
struct rituoApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var onboardingService = OnboardingService()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    if onboardingService.shouldShowOnboarding {
                        OnboardingView(onboardingService: onboardingService)
                            .preferredColorScheme(.dark)
                    } else {
                        ContentView(authService: authService)
                    }
                } else {
                    AuthView(authService: authService)
                        .preferredColorScheme(.dark)
                }
            }
            .animation(.easeInOut, value: authService.isAuthenticated)
            .animation(.easeInOut, value: onboardingService.shouldShowOnboarding)
        }
    }
}

struct ContentView: View {
    @ObservedObject var authService: AuthService
    @StateObject private var nfcManager = NFCManager()
    @StateObject private var appBlockingManager = AppBlockingManager()
    @State private var isAppBlockingPresented = false

    private var displayName: String {
        authService.currentUser?.name ?? "Guest"
    }

    private var usernameForNFC: String {
        if let name = authService.currentUser?.name, !name.isEmpty {
            return name
        }
        return authService.currentUser?.id ?? "guest"
    }

    var body: some View {
        TabView {
            // Tab 1: Home
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Welcome \(displayName)")
                    .font(.largeTitle)
                    .bold()

                Text("Your NFC dashboard is ready.")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Use the Read tab to scan tag information and the Write tab to save new data.")
                    .padding()
                    .multilineTextAlignment(.center)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                VStack(spacing: 12) {
                    Text(appBlockingManager.isShieldingEnabled ? "App blocking is currently on." : "Block distracting apps whenever you need focus time.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

                    Button("Manage Blocked Apps") {
                        isAppBlockingPresented = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)

                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .sheet(isPresented: $isAppBlockingPresented) {
                AppBlockingView(manager: appBlockingManager)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            // Tab 2: Read
            VStack(spacing: 20) {
                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Tag Information")
                    .font(.headline)

                Text(nfcManager.scannedData)
                    .padding()
                    .multilineTextAlignment(.center)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                Button("Scan Tag") {
                    nfcManager.startScanning()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .tabItem {
                Label("Read", systemImage: "dot.radiowaves.left.and.right")
            }

            // Tab 3: Write
            VStack(spacing: 20) {
                Text("Write to Tag")
                    .font(.largeTitle)
                    .bold()

                Text("Data to be written:")
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Username: \(usernameForNFC)")
                    Text("Timestamp: Current Time")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

                Button("Write Data") {
                    nfcManager.startWriting(username: usernameForNFC)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding()
            .tabItem {
                Label("Write", systemImage: "square.and.pencil")
            }
        }
    }
}
