import Foundation

struct Job: Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    let title: String
    let companyName: String
    let location: String
    let salaryRange: String
    let description: String
    let companyLogoURL: URL?
    let jobType: String
    let category: String
    let applyURL: URL?

    var displaySalary: String {
        guard !salaryRange.isEmpty else { return "Salary not disclosed" }
        return SalaryFormatter.inrDisplay(from: salaryRange)
    }

    var displayLocation: String {
        location.isEmpty ? "Location not specified" : location
    }
}

extension Job {
    static let previewSamples: [Job] = [
        Job(
            id: 1,
            title: "iOS Engineer",
            companyName: "Salaria",
            location: "Remote — Worldwide",
            salaryRange: "₹99L - ₹1.3Cr",
            description: "Build scalable mobile experiences with SwiftUI and UIKit.",
            companyLogoURL: nil,
            jobType: "full_time",
            category: "Software Development",
            applyURL: URL(string: "https://example.com")
        ),
        Job(
            id: 2,
            title: "Head of Sales",
            companyName: "The Land Geek",
            location: "Worldwide",
            salaryRange: "₹90L - ₹1.9Cr",
            description: "Lead and scale a high-performing sales organization.",
            companyLogoURL: nil,
            jobType: "contract",
            category: "Sales",
            applyURL: URL(string: "https://example.com")
        )
    ]
}
