import Cocoa

class HistoryView: NSView {
    private var stackView: NSStackView!
    private var history: [String]
    
    init(history: [String]) {
        self.history = history
        super.init(frame: NSMakeRect(0, 0, 350, 400))
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        // ScrollView pentru conținut
        let scrollView = NSScrollView(frame: bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true

        // DocumentView pentru conținutul derulabil
        let documentView = NSView()
        documentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = documentView

        // StackView pentru rânduri (afișare istoricului)
        stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false

        documentView.addSubview(stackView)

        // Constrângeri pentru StackView
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: documentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: documentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: documentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: documentView.bottomAnchor, constant: -10) // Asigurăm extinderea în jos
        ])

        // Constrângere pentru ca documentView să își ajusteze dimensiunea pe verticală
        NSLayoutConstraint.activate([
            documentView.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),
            documentView.heightAnchor.constraint(greaterThanOrEqualTo: stackView.heightAnchor)
        ])

        // Adăugăm scrollView în view-ul principal
        addSubview(scrollView)
        reloadStackView()
    }

    func updateHistory(history: [String]) {
        self.history = history
        reloadStackView()
    }

    private func reloadStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Adăugăm datele de sus în jos
        for entry in history {
            let row = createRow(for: entry)
            stackView.addArrangedSubview(row)
        }
    }

    private func createRow(for entry: String) -> NSView {
        let rowView = NSView()
        rowView.wantsLayer = true
        rowView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        rowView.layer?.cornerRadius = 8
        rowView.layer?.borderColor = NSColor.separatorColor.cgColor
        rowView.layer?.borderWidth = 1

        let label = NSTextField(labelWithString: entry)
        label.font = NSFont.systemFont(ofSize: 12)
        label.textColor = NSColor.labelColor
        label.translatesAutoresizingMaskIntoConstraints = false

        let circleView = NSView()
        circleView.wantsLayer = true
        circleView.layer = CALayer()
        circleView.layer?.backgroundColor = entry.contains("Online") ? NSColor.systemGreen.cgColor : NSColor.systemRed.cgColor
        circleView.layer?.cornerRadius = 6
        circleView.translatesAutoresizingMaskIntoConstraints = false

        rowView.addSubview(label)
        rowView.addSubview(circleView)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),

            circleView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -10),
            circleView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 12),
            circleView.heightAnchor.constraint(equalToConstant: 12),

            rowView.heightAnchor.constraint(equalToConstant: 36)
        ])

        return rowView
    }
}
