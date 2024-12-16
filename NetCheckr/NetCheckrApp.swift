import Cocoa
import ServiceManagement

@main
class NetCheckrApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        
        // Gestionăm Launch at Login la pornire, dacă este necesar
        do {
            try checkAndManageLaunchAtLogin()
        } catch {
            print("Error managing Launch at Login at startup: \(error.localizedDescription)")
        }
        
        app.run()
    }
    
    /// Verifică starea curentă și gestionează Launch at Login
    static func checkAndManageLaunchAtLogin() throws {
        let helperID = "dev.padrewin.LaunchAtLoginHelper"
        
        if #available(macOS 13.0, *) {
            let helper = SMAppService.loginItem(identifier: helperID)
            
            // Verificăm starea curentă a helperului
            if helper.status == .notRegistered {
                print("Helper is not registered. Attempting to register...")
                try helper.register()
                print("Helper registered successfully.")
            } else if helper.status == .enabled {
                print("Helper is already registered and enabled.")
            } else {
                print("Unknown helper status: \(helper.status)")
            }
        } else {
            throw NSError(domain: "dev.padrewin.NetCheckr", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported macOS version"])
        }
    }

    /// Funcție pentru gestionarea manuală a Launch at Login din setări
    static func manageLaunchAtLogin(isEnabled: Bool) {
        let helperID = "dev.padrewin.LaunchAtLoginHelper"

        if #available(macOS 13.0, *) {
            let helper = SMAppService.loginItem(identifier: helperID)
            do {
                if isEnabled {
                    try helper.register()
                    print("Helper successfully registered for Launch at Login.")
                } else {
                    try helper.unregister()
                    print("Helper successfully unregistered for Launch at Login.")
                }
            } catch {
                print("Failed to manage LaunchAtLogin Helper: \(error.localizedDescription)")
            }
        } else {
            print("Launch at Login is not supported on this version of macOS.")
        }
    }
}
