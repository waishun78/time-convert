import Foundation

enum ConversionResult {
    case epochToTime(Date)
    case timeToEpoch(seconds: Int64, milliseconds: Int64)
}

enum TimeProcessor {
    private static let inputFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        return f
    }()

    private static let manualDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yy"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        return f
    }()

    private static let manualTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        return f
    }()

    static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "ddMMMyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        return f
    }()

    static let localFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        return f
    }()

    static let utcFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    static func process(_ text: String) -> ConversionResult? {
        let s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let len = s.count

        // Fast path: epoch (10 = seconds, 13 = milliseconds)
        if len == 10 || len == 13 {
            if s.allSatisfy(\.isNumber), let value = Double(s) {
                let secs = len == 13 ? value / 1000.0 : value
                let date = Date(timeIntervalSince1970: secs)
                let year = Calendar.current.component(.year, from: date)
                if (2000...2100).contains(year) {
                    return .epochToTime(date)
                }
            }
        }

        // Second path: datetime string "yyyy-MM-dd HH:mm:ss"
        guard (19...25).contains(len) else { return nil }

        if let date = inputFormatter.date(from: s) {
            let secs = Int64(date.timeIntervalSince1970)
            return .timeToEpoch(seconds: secs, milliseconds: secs * 1000)
        }

        return nil
    }

    // Combines a "dd MMM yy" date string and "HH:mm:ss" time string into epoch values (local time).
    static func parseManual(date dateStr: String, time timeStr: String) -> (seconds: Int64, milliseconds: Int64)? {
        let d = dateStr.trimmingCharacters(in: .whitespaces)
        let t = timeStr.trimmingCharacters(in: .whitespaces)
        guard !d.isEmpty, !t.isEmpty,
              let datePart = manualDateFormatter.date(from: d),
              let timePart = manualTimeFormatter.date(from: t) else { return nil }

        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        var comps = cal.dateComponents([.year, .month, .day], from: datePart)
        let timeComps = cal.dateComponents([.hour, .minute, .second], from: timePart)
        comps.hour = timeComps.hour
        comps.minute = timeComps.minute
        comps.second = timeComps.second
        comps.timeZone = TimeZone.current

        guard let result = cal.date(from: comps) else { return nil }
        let secs = Int64(result.timeIntervalSince1970)
        return (seconds: secs, milliseconds: secs * 1000)
    }
}
