import Foundation

class SettingsStorage {
    static let shared = SettingsStorage()
    
    private init() {}
    
    func saveSettings(_ settings: Settings) {
        let defaults = UserDefaults.standard
        defaults.set(settings.launchAtLogin, forKey: "launchAtLogin")
        defaults.set(settings.showIconPreference.rawValue, forKey: "showIconPreference")
        defaults.set(settings.notificationsEnabled, forKey: "notificationsEnabled")
        print("Settings saved: \(settings)")
    }

    func loadSettings() -> Settings {
        let defaults = UserDefaults.standard

        let launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        let showIconPreferenceRawValue = defaults.string(forKey: "showIconPreference") ?? IconPreference.always.rawValue
        let showIconPreference = IconPreference(rawValue: showIconPreferenceRawValue) ?? .always
        let notificationsEnabled = defaults.bool(forKey: "notificationsEnabled")

        return Settings(
            launchAtLogin: launchAtLogin,
            showIconPreference: showIconPreference,
            notificationsEnabled: notificationsEnabled
        )
    }
}
