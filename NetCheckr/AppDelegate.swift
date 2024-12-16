import Cocoa
import UserNotifications
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var settingsWindowController: SettingsWindowController?
    var statusItem: NSStatusItem!
    var isOnline: Bool = true
    var lastOfflineTime: Date?
    var historyManager = HistoryManager()
    var internetChecker = InternetChecker() // Folosește NWPathMonitor
    var offlineTimer: Timer? // Timer pentru actualizarea timpului în meniu

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        
        let currentSettings = AppSettingsManager.shared.load()
        
        if currentSettings.showIconPreference == .whenOffline && isOnline {
            print("App running in 'When Offline' mode while online. Showing settings window.")
            showSettingsWindow()
            return
        }
        
        createStatusItem()
        updateStatusItemVisibility()
        monitorNetworkChanges()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            // Dacă există deja ferestre vizibile, le aducem în prim-plan
            NSApplication.shared.windows.forEach { $0.makeKeyAndOrderFront(nil) }
        } else {
            // Dacă nu există ferestre vizibile, deschidem fereastra de setări
            showSettingsWindow()
        }
        return true
    }
    
    func createStatusItem() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            if let button = statusItem.button {
                button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
                button.image?.isTemplate = true // Iconiță monocromă
            }
            print("Status item created.")
        }
        statusItem.menu = createMenu()
    }

    func configureNotifications() {
        // Solicitați permisiuni pentru notificări
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
            }
        }
    }

    // Monitorizează schimbările de conexiune folosind InternetChecker
    func monitorNetworkChanges() {
        internetChecker.checkInternetConnectivity { [weak self] online in
            self?.updateStatus(online: online)
        }
    }
    
    func updateStatusItemVisibility() {
        let settings = AppSettingsManager.shared.load() // Reîncarcă setările
        print("Updating status item visibility. Current setting: \(settings.showIconPreference.rawValue), Online status: \(isOnline)")

        switch settings.showIconPreference {
        case .always:
            showStatusItem()
        case .whenOffline:
            if isOnline {
                hideStatusItem() // Ascunde iconița dacă utilizatorul este online
            } else {
                showStatusItem() // Arată iconița dacă utilizatorul este offline
            }
        }
    }

    func hideStatusItem() {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
            print("Status item completely removed.")
        }
    }

    func showStatusItem() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            if let button = statusItem.button {
                button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
                button.image?.isTemplate = true
            }
            statusItem.menu = createMenu()
            print("Status item successfully created.")
        }
    }
    
    func updateStatus(online: Bool) {
        DispatchQueue.main.async {
            if self.isOnline != online {
                self.isOnline = online

                if online {
                    print("Back Online")
                    self.lastOfflineTime = nil
                    self.stopOfflineTimer()
                    self.showNotificationIfEnabled(
                        title: "Back Online",
                        message: "You are back online. ✅",
                        notificationsEnabled: AppSettingsManager.shared.load().notificationsEnabled
                    )
                    self.historyManager.addEntry("Online at \(self.formatDate(Date()))")
                } else {
                    print("Offline")
                    self.lastOfflineTime = Date()
                    self.startOfflineTimer()
                    self.showNotificationIfEnabled(
                        title: "Offline",
                        message: "You are offline. ❌",
                        notificationsEnabled: AppSettingsManager.shared.load().notificationsEnabled
                    )
                    self.historyManager.addEntry("Offline at \(self.formatDate(Date()))")
                }

                // Actualizează vizibilitatea iconiței
                self.updateStatusItemVisibility()
            }
        }
    }

    func showNotificationIfEnabled(title: String, message: String, notificationsEnabled: Bool) {
        print("Attempting to show notification. Notifications enabled in settings: \(notificationsEnabled)")
        
        guard notificationsEnabled else {
            print("Notifications are disabled in app settings. Skipping notification.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to deliver notification: \(error.localizedDescription)")
            } else {
                print("Notification successfully delivered: \(title)")
            }
        }
    }

    func sendOfflineNotification() {
        let content = UNMutableNotificationContent()
        content.title = "NetCheckr"
        content.body = "Your device is offline. Check your network settings."
        content.sound = .default

        let request = UNNotificationRequest(identifier: "OfflineNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

    func sendOnlineNotification() {
        let content = UNMutableNotificationContent()
        content.title = "NetCheckr"
        content.body = "You're back online."
        content.sound = .default

        let request = UNNotificationRequest(identifier: "OnlineNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

    func updateIcon(for online: Bool) {
        if let button = statusItem.button {
            let iconName = "globe"
            let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
            image?.isTemplate = true // Iconiță monocromă permanentă
            button.image = image
        }
    }

    func startOfflineTimer() {
        stopOfflineTimer() // Ne asigurăm că nu există un timer activ

        offlineTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                // Actualizăm doar meniul
                self.statusItem.menu = self.createMenu()
            }
        }
    }

    func stopOfflineTimer() {
        offlineTimer?.invalidate()
        offlineTimer = nil
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    func createMenu() -> NSMenu {
        let menu = NSMenu()

        let statusItem = NSMenuItem()
        statusItem.attributedTitle = getStatusAttributedString()
        menu.addItem(statusItem)
        menu.addItem(NSMenuItem.separator())

        let historyItem = NSMenuItem(
            title: "History",
            action: #selector(showHistory),
            keyEquivalent: "H"
        )
        menu.addItem(historyItem)

        let settingsItem = NSMenuItem(
            title: "Settings",
            action: #selector(showSettings),
            keyEquivalent: ","
        )
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        return menu
    }

    func getStatusAttributedString() -> NSAttributedString {
        let statusText: String
        let emoji: String
        let color: NSColor

        if isOnline {
            statusText = "Online"
            emoji = "✅"
            color = .systemGreen
        } else {
            let offlineDuration = timeSinceLastOffline()
            statusText = "Offline for \(offlineDuration)"
            emoji = "❌"
            color = .systemRed
        }

        let fullText = "\(emoji) \(statusText)"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: NSFont.systemFont(ofSize: 14)
        ]

        return NSAttributedString(string: fullText, attributes: attributes)
    }

    func timeSinceLastOffline() -> String {
        guard let lastOffline = lastOfflineTime else { return "N/A" }
        let interval = Int(Date().timeIntervalSince(lastOffline))

        if interval < 60 {
            return "\(interval) second(s)"
        } else if interval < 3600 {
            let minutes = interval / 60
            return "\(minutes) minute(s)"
        } else if interval < 86400 {
            let hours = interval / 3600
            return "\(hours) hour(s)"
        } else {
            let days = interval / 86400
            return "\(days) day(s)"
        }
    }

    var historyWindowController: HistoryWindowController?

    @objc func showHistory() {
        showAppInDock() // Afișează aplicația în Dock

        if historyWindowController == nil {
            historyWindowController = HistoryWindowController(history: historyManager.getHistory())
        }
        historyWindowController?.updateHistory(history: historyManager.getHistory())
        historyWindowController?.showWindow(self)

        historyWindowController?.window?.delegate = self // Ascundem iconița din Dock când fereastra este închisă
    }
    
    func showSettingsWindow() {
        if settingsWindowController == nil {
            let currentSettings = AppSettingsManager.shared.load()
            settingsWindowController = SettingsWindowController(settings: currentSettings)
        }
        settingsWindowController?.showWindow(self)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    @objc func showSettings() {
        showAppInDock() // Afișează aplicația în Dock

        let currentSettings = AppSettingsManager.shared.load()
        settingsWindowController = SettingsWindowController(settings: currentSettings)
        settingsWindowController?.showWindow(self)

        settingsWindowController?.window?.delegate = self // Ascundem iconița din Dock când fereastra este închisă
    }

    func applySettings(_ settings: Settings) {
        print("Applying settings: launchAtLogin = \(settings.launchAtLogin), notificationsEnabled = \(settings.notificationsEnabled)")

        // Actualizăm starea pentru notificări
        if settings.notificationsEnabled {
            print("Notifications enabled.")
        } else {
            print("Notifications disabled.")
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("Notification received while app is in foreground: \(notification.request.content.title)")
        completionHandler([.banner, .sound]) // Afișează notificarea ca banner și redă sunetul
    }
}
extension AppDelegate {
    func showAppInDock() {
        NSApplication.shared.setActivationPolicy(.regular) // Afișează iconița în Dock
        NSApplication.shared.activate(ignoringOtherApps: true) // Activează aplicația
    }

    func hideAppFromDock() {
        NSApplication.shared.setActivationPolicy(.accessory) // Ascunde iconița din Dock
    }
}
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        hideAppFromDock() // Ascunde iconița când fereastra este închisă
    }
}
