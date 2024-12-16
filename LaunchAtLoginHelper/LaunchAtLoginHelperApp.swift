import Cocoa

@main
class LaunchAtLoginHelperApp: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Bundle identifier pentru aplicația principală
        let mainAppBundleIdentifier = "dev.padrewin.NetCheckr"

        // Verificăm dacă aplicația principală rulează deja
        let runningApps = NSWorkspace.shared.runningApplications
        let isMainAppRunning = runningApps.contains {
            $0.bundleIdentifier == mainAppBundleIdentifier
        }

        // Dacă aplicația principală nu rulează, o lansăm
        if !isMainAppRunning {
            let mainAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: mainAppBundleIdentifier)
            if let appURL = mainAppURL {
                NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration()) { _, error in
                    if let error = error {
                        print("Failed to launch main app: \(error)")
                    } else {
                        print("Main app launched successfully.")
                    }
                }
            }
        }

        // Terminăm helper-ul
        NSApp.terminate(nil)
    }
}
