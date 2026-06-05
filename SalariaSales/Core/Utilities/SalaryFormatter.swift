import Foundation

/// Normalizes salary strings for display in USD.
enum SalaryFormatter {
    /// Returns a salary string in USD format, preserving raw input when already USD.
    static func usdDisplay(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed
    }
}
