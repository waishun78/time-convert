import AppKit

final class ClipboardMonitor: ObservableObject {
    @Published var result: ConversionResult?
    @Published var menuBarLabel = ""
    @Published var inputText = ""

    private var pollTimer: Timer?
    private var resetTimer: Timer?
    private var lastChangeCount: Int

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    private func poll() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount
        guard let text = pb.string(forType: .string) else { return }
        handle(text)
    }

    private func handle(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let r = TimeProcessor.process(trimmed) else { return }

        // Set label before result so the menu bar never flashes an empty string
        switch r {
        case .epochToTime(let date):
            menuBarLabel = TimeProcessor.timeFormatter.string(from: date)
        case .timeToEpoch(let s, _):
            menuBarLabel = "\(s)"
        }

        inputText = trimmed
        result = r
        scheduleReset()
    }

    private func scheduleReset() {
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { [weak self] _ in
            self?.result = nil
            self?.menuBarLabel = ""
            self?.inputText = ""
        }
    }

    deinit {
        pollTimer?.invalidate()
        resetTimer?.invalidate()
    }
}
