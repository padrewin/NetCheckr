import Cocoa

class HistoryWindowController: NSWindowController {
    private var historyView: HistoryView!

    convenience init(history: [String]) {
        self.init(window: NSWindow(
            contentRect: NSMakeRect(0, 0, 350, 400),
            styleMask: [.titled, .closable], // Fixăm fereastra
            backing: .buffered,
            defer: false
        ))

        window?.title = "NetCheckr History"
        window?.isMovable = true
        window?.styleMask.remove(.resizable)
        window?.setContentSize(NSSize(width: 350, height: 400)) // Dimensiune fixă

        historyView = HistoryView(history: history)
        window?.contentView = historyView
        window?.center()
    }

    // Funcție pentru actualizarea datelor
    func updateHistory(history: [String]) {
        historyView.updateHistory(history: history)
    }
}
