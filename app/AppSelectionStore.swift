import FamilyControls
import Foundation

struct AppSelectionStore {
    private let defaults: UserDefaults
    private let selectionKey = "app.blocking.selection"
    private let shieldingKey = "app.blocking.isShieldingEnabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSelection() -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: selectionKey) else {
            return FamilyActivitySelection()
        }

        return (try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)) ?? FamilyActivitySelection()
    }

    func saveSelection(_ selection: FamilyActivitySelection) {
        guard let data = try? JSONEncoder().encode(selection) else {
            return
        }

        defaults.set(data, forKey: selectionKey)
    }

    func loadShieldingState() -> Bool {
        defaults.bool(forKey: shieldingKey)
    }

    func saveShieldingState(_ isEnabled: Bool) {
        defaults.set(isEnabled, forKey: shieldingKey)
    }
}
