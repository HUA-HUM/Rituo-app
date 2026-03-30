//
//  appApp.swift
//  app
//
//  Created by Jesus Lopez on 11/3/26.
//

import SwiftUI

@main
struct rituoApp: App {
    var body: some Scene {
        WindowGroup{
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject var nfcManager = NFCManager()

    var body: some View {
        TabView {
            // Tab 1: Home
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Welcome user123")
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
            }
            .padding()
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
                    Text("Username: user123")
                    Text("Timestamp: Current Time")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

                Button("Write Data") {
                    nfcManager.startWriting(username: "user123")
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
