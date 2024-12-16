import Cocoa
import LaunchAtLogin

class SettingsWindowController: NSWindowController {
    private var launchAtLoginToggle: NSSwitch!
    private var notificationsToggle: NSSwitch!
    private var iconPreferencePopup: NSPopUpButton! // Pop-up pentru showIconPreference

    private var settings: Settings

    init(settings: Settings) {
        self.settings = settings
        let window = NSWindow(
            contentRect: NSMakeRect(0, 0, 350, 250), // Ajustăm dimensiunea ferestrei
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "NetCheckr Settings"
        window.styleMask.remove(.resizable)
        super.init(window: window)

        window.center()

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let mainStackView = NSStackView()
        mainStackView.orientation = .vertical
        mainStackView.spacing = 12
        mainStackView.alignment = .leading
        mainStackView.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)

        // Launch at login toggle
        let launchAtLoginBox = createGroupBox(title: "Launch at login")
        launchAtLoginToggle = NSSwitch()
        launchAtLoginToggle.state = settings.launchAtLogin ? .on : .off
        launchAtLoginToggle.target = self
        launchAtLoginToggle.action = #selector(launchAtLoginChanged)
        positionControl(launchAtLoginToggle, in: launchAtLoginBox)
        mainStackView.addArrangedSubview(launchAtLoginBox)

        // Notifications toggle
        let notificationsBox = createGroupBox(title: "Enable Notifications")
        notificationsToggle = NSSwitch()
        notificationsToggle.state = settings.notificationsEnabled ? .on : .off
        notificationsToggle.target = self
        notificationsToggle.action = #selector(notificationsChanged)
        positionControl(notificationsToggle, in: notificationsBox)
        mainStackView.addArrangedSubview(notificationsBox)

        // Icon preference pop-up
        let iconPreferenceBox = createGroupBox(title: "Show Icon Preference")
        iconPreferencePopup = NSPopUpButton()
        iconPreferencePopup.addItems(withTitles: ["Always", "When Offline"]) // Fără "Never"
        iconPreferencePopup.selectItem(withTitle: settings.showIconPreference.rawValue)
        iconPreferencePopup.target = self
        iconPreferencePopup.action = #selector(iconPreferenceChanged)
        positionControl(iconPreferencePopup, in: iconPreferenceBox)
        mainStackView.addArrangedSubview(iconPreferenceBox)

        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // Funcție apelată când toggle-ul Launch at Login este schimbat
    @objc private func launchAtLoginChanged() {
        settings.launchAtLogin = (launchAtLoginToggle.state == .on)
        AppSettingsManager.shared.save(settings)
        print("Launch at login set to: \(settings.launchAtLogin)")

        if settings.launchAtLogin {
            LaunchAtLogin.isEnabled = true
        } else {
            LaunchAtLogin.isEnabled = false
        }
    }

    // Funcție apelată când toggle-ul Enable Notifications este schimbat
    @objc private func notificationsChanged() {
        settings.notificationsEnabled = (notificationsToggle.state == .on)
        AppSettingsManager.shared.save(settings)
        print("Notifications enabled: \(settings.notificationsEnabled)")
    }

    // Funcție apelată când opțiunea Show Icon Preference este schimbată
    @objc private func iconPreferenceChanged() {
        if let selectedTitle = iconPreferencePopup.selectedItem?.title,
           let newPreference = IconPreference(rawValue: selectedTitle) {
            settings.showIconPreference = newPreference
            AppSettingsManager.shared.save(settings)
            print("Show Icon Preference set to: \(settings.showIconPreference.rawValue)")

            // Forțează actualizarea vizibilității iconiței
            let appDelegate = NSApplication.shared.delegate as? AppDelegate
            appDelegate?.updateStatusItemVisibility()
        }
    }

    // Creează un grup cu borduri rotunjite
    private func createGroupBox(title: String) -> NSBox {
        let box = NSBox()
        box.boxType = .custom
        box.contentViewMargins = NSSize(width: 10, height: 10)
        box.wantsLayer = true
        box.layer?.borderColor = NSColor.separatorColor.cgColor
        box.layer?.borderWidth = 1
        box.layer?.cornerRadius = 8
        box.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.2).cgColor

        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: box.centerYAnchor)
        ])
        return box
    }

    // Plasează controlul în partea dreaptă a grupului
    private func positionControl(_ control: NSView, in box: NSBox) {
        control.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(control)

        NSLayoutConstraint.activate([
            control.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8),
            control.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            box.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
