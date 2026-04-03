import FamilyControls
import SwiftUI

struct AppBlockingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var manager: AppBlockingManager

    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    Label(manager.authorizationDescription, systemImage: manager.canManageApps ? "checkmark.shield.fill" : "exclamationmark.shield")
                        .foregroundStyle(manager.canManageApps ? .green : .primary)

                    Label(manager.isShieldingEnabled ? "Blocking is currently on." : "Blocking is currently off.", systemImage: manager.isShieldingEnabled ? "hand.raised.fill" : "hand.raised")
                }

                Section("Selected Apps") {
                    Text(manager.selectionDescription)
                        .foregroundStyle(.secondary)

                    Button("Choose Apps") {
                        manager.presentPicker()
                    }
                    .disabled(!manager.canManageApps)
                }

                Section("Actions") {
                    if !manager.canManageApps {
                        Button("Request Screen Time Access") {
                            Task {
                                await manager.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button("Block Apps") {
                        manager.blockSelectedApps()
                    }
                    .disabled(!manager.canManageApps || !manager.hasSelection)

                    Button("Unblock Apps") {
                        manager.unblockSelectedApps()
                    }
                    .disabled(!manager.isShieldingEnabled)
                }
            }
            .navigationTitle("App Blocking")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                manager.refreshAuthorizationStatus()
            }
        }
        .familyActivityPicker(
            isPresented: $manager.isPickerPresented,
            selection: $manager.selection
        )
        .alert("App Blocking", isPresented: errorAlertIsPresented) {
            Button("OK", role: .cancel) {
                manager.errorMessage = nil
            }
        } message: {
            Text(manager.errorMessage ?? "")
        }
    }

    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: {
                manager.errorMessage != nil
            },
            set: { isPresented in
                if !isPresented {
                    manager.errorMessage = nil
                }
            }
        )
    }
}
