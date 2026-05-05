import SwiftUI

@main
struct TimeConvertApp: App {
    @StateObject private var monitor = ClipboardMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(monitor)
        } label: {
            if monitor.result == nil {
                Image(systemName: "clock")
                    .symbolRenderingMode(.hierarchical)
            } else {
                Text(monitor.menuBarLabel)
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window)
    }
}
