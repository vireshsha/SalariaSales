import Foundation

/// Converts salary strings (typically USD from Remotive) into INR display format.
enum SalaryFormatter {
    /// Approximate USD → INR rate used for API salary conversion.
    static let usdToInrRate: Double = 83

    /// Returns a salary string formatted in INR (₹), converting `$` amounts when present.
    static func inrDisplay(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        if trimmed.contains("₹") || trimmed.lowercased().contains("inr") {
            return trimmed
        }

        guard let regex = try? NSRegularExpression(
            pattern: #"\$\s*(\d+(?:\.\d+)?)\s*k"#,
            options: .caseInsensitive
        ) else {
            return trimmed.replacingOccurrences(of: "$", with: "₹")
        }

        let nsString = trimmed as NSString
        let matches = regex.matches(in: trimmed, range: NSRange(location: 0, length: nsString.length))
        guard !matches.isEmpty else {
            return trimmed.replacingOccurrences(of: "$", with: "₹")
        }

        var result = trimmed
        for match in matches.reversed() {
            guard match.numberOfRanges > 1 else { continue }
            let amountString = nsString.substring(with: match.range(at: 1))
            guard let amount = Double(amountString) else { continue }
            let inrAmount = amount * 1_000 * usdToInrRate
            let replacement = formatINRAmount(inrAmount)
            result = (result as NSString).replacingCharacters(in: match.range, with: replacement)
        }
        return result
    }

    private static func formatINRAmount(_ amount: Double) -> String {
        if amount >= 10_000_000 {
            return String(format: "₹%.1fCr", amount / 10_000_000)
        }
        if amount >= 100_000 {
            return String(format: "₹%.1fL", amount / 100_000)
        }
        return String(format: "₹%.0f", amount)
    }
}
