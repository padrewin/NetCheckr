import Foundation

enum IconPreference: String {
    case always = "Always"
    case whenOffline = "When Offline"
}

struct Settings {
    var launchAtLogin: Bool = false
    var showIconPreference: IconPreference = .always
    var notificationsEnabled: Bool = true // Nou: activează notificările implicit
}
