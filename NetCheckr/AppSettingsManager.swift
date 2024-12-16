import Foundation

class AppSettingsManager {
    static let shared = AppSettingsManager()
    private init() {}

    private let defaults = UserDefaults.standard

    func save(_ settings: Settings) {
        defaults.set(settings.launchAtLogin, forKey: "launchAtLogin")
        defaults.set(settings.notificationsEnabled, forKey: "notificationsEnabled")
        defaults.set(settings.showIconPreference.rawValue, forKey: "showIconPreference")
        print("Settings saved: \(settings)")
    }

    func load() -> Settings {
        let launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        let notificationsEnabled = defaults.bool(forKey: "notificationsEnabled")
        let showIconPreferenceRawValue = defaults.string(forKey: "showIconPreference") ?? IconPreference.always.rawValue
        let showIconPreference = IconPreference(rawValue: showIconPreferenceRawValue) ?? .always

        let loadedSettings = Settings(
            launchAtLogin: launchAtLogin,
            showIconPreference: showIconPreference,
            notificationsEnabled: notificationsEnabled
        )
        print("Settings loaded: \(loadedSettings)")
        return loadedSettings
    }
}
