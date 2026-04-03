import Combine
import FamilyControls
import Foundation
import ManagedSettings

@MainActor
final class AppBlockingManager: ObservableObject {
    @Published var selection: FamilyActivitySelection {
        didSet {
            selectionStore.saveSelection(selection)
        }
    }
    @Published var isPickerPresented = false
    @Published var errorMessage: String?
    @Published private(set) var authorizationStatus: AuthorizationStatus
    @Published private(set) var isShieldingEnabled: Bool

    private let authorizationCenter: AuthorizationCenter
    private let managedSettingsStore = ManagedSettingsStore()
    private let selectionStore: AppSelectionStore
    private var cancellables = Set<AnyCancellable>()

    init(
        authorizationCenter: AuthorizationCenter = .shared,
        selectionStore: AppSelectionStore? = nil
    ) {
        let resolvedSelectionStore = selectionStore ?? AppSelectionStore()
        self.authorizationCenter = authorizationCenter
        self.selectionStore = resolvedSelectionStore
        self.selection = resolvedSelectionStore.loadSelection()
        self.authorizationStatus = authorizationCenter.authorizationStatus
        self.isShieldingEnabled = resolvedSelectionStore.loadShieldingState()

        authorizationCenter.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.authorizationStatus = status
            }
            .store(in: &cancellables)
    }

    var canManageApps: Bool {
        authorizationStatus == .approved
    }

    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }

    var authorizationDescription: String {
        switch authorizationStatus {
        case .approved:
            return "Screen Time access approved."
        case .denied:
            return "Screen Time access denied. Re-enable it in Settings if needed."
        case .notDetermined:
            return "Screen Time access has not been requested yet."
        @unknown default:
            return "Screen Time access status is unavailable."
        }
    }

    var selectionDescription: String {
        if !hasSelection {
            return "No apps or categories selected yet."
        }

        let appCount = selection.applicationTokens.count
        let categoryCount = selection.categoryTokens.count
        return "\(formattedCount(appCount, singular: "app")) and \(formattedCount(categoryCount, singular: "category")) selected."
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = authorizationCenter.authorizationStatus
    }

    func requestAuthorization() async {
        do {
            errorMessage = nil
            try await authorizationCenter.requestAuthorization(for: .individual)
            refreshAuthorizationStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func presentPicker() {
        guard canManageApps else {
            errorMessage = "Authorize Screen Time access before choosing apps."
            return
        }

        errorMessage = nil
        isPickerPresented = true
    }

    func blockSelectedApps() {
        guard canManageApps else {
            errorMessage = "Authorize Screen Time access before blocking apps."
            return
        }

        guard hasSelection else {
            errorMessage = "Choose at least one app or category to block."
            return
        }

        managedSettingsStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        managedSettingsStore.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        isShieldingEnabled = true
        selectionStore.saveShieldingState(true)
    }

    func unblockSelectedApps() {
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
        isShieldingEnabled = false
        selectionStore.saveShieldingState(false)
    }

    private func formattedCount(_ count: Int, singular: String) -> String {
        count == 1 ? "1 \(singular)" : "\(count) \(singular)s"
    }
}
