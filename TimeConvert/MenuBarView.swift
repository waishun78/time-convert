import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var monitor: ClipboardMonitor

    var body: some View {
        VStack(spacing: 0) {
            // Clipboard result — only shown when clipboard has a valid conversion
            if let result = monitor.result {
                ClipboardSection(result: result, inputText: monitor.inputText)
                Divider()
            }

            ManualInputSection()

            Divider()

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("Quit TimeConvert", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 280)
    }
}

// MARK: - Clipboard Section

private struct ClipboardSection: View {
    let result: ConversionResult
    let inputText: String

    var body: some View {
        VStack(spacing: 0) {
            // Input pill
            HStack {
                Image(systemName: result.isEpoch ? "number" : "calendar")
                    .foregroundStyle(.secondary)
                    .imageScale(.small)
                Text(inputText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary, in: Rectangle())

            VStack(spacing: 0) {
                switch result {
                case .epochToTime(let date):
                    ResultRow(label: "Local", value: TimeProcessor.localFormatter.string(from: date), icon: "clock")
                    Divider().padding(.leading, 36)
                    ResultRow(label: "UTC", value: TimeProcessor.utcFormatter.string(from: date), icon: "globe")
                case .timeToEpoch(let s, let ms):
                    ResultRow(label: "Seconds", value: "\(s)", icon: "s.circle")
                    Divider().padding(.leading, 36)
                    ResultRow(label: "Milliseconds", value: "\(ms)", icon: "m.circle")
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Manual Input Section

private struct ManualInputSection: View {
    @State private var dateText = ""
    @State private var timeText = ""

    private var epochResult: (seconds: Int64, milliseconds: Int64)? {
        TimeProcessor.parseManual(date: dateText, time: timeText)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Convert to Epoch · Local")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 8)

            HStack(spacing: 8) {
                InputField(icon: "calendar", placeholder: "05 May 26", text: $dateText)
                InputField(icon: "clock", placeholder: "14:32:10", text: $timeText)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            if let r = epochResult {
                Divider().padding(.leading, 12)
                VStack(spacing: 0) {
                    ResultRow(label: "Seconds", value: "\(r.seconds)", icon: "s.circle")
                    Divider().padding(.leading, 36)
                    ResultRow(label: "Milliseconds", value: "\(r.milliseconds)", icon: "m.circle")
                }
                .padding(.vertical, 4)
            }
        }
    }
}

private struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .imageScale(.small)
                .frame(width: 14)
            TextField(placeholder, text: $text)
                .font(.system(.callout, design: .monospaced))
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Shared Components

private struct ResultRow: View {
    let label: String
    let value: String
    let icon: String
    @State private var copied = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .imageScale(.small)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button(copied ? "Copied" : "Copy") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(value, forType: .string)
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    copied = false
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .tint(copied ? .green : .accentColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

private extension ConversionResult {
    var isEpoch: Bool {
        if case .epochToTime = self { return true }
        return false
    }
}
