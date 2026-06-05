import Foundation

/// Remote and local URLs for job data sources.
enum JobEndpoints {
    /// Live Remotive public API (primary source).
    static let liveJobsURL = URL(string: "https://remotive.com/api/remote-jobs")!

    /// Static JSON mirror of `jobs_fallback.json` (same Remotive schema).
    /// Hosted on GitHub at:
    /// https://raw.githubusercontent.com/vireshsha/SalariaSales/main/SalariaSales/Resources/jobs_fallback.json
    static let fallbackJobsURL = URL(
        string: "https://raw.githubusercontent.com/vireshsha/SalariaSales/main/SalariaSales/Resources/jobs_fallback.json"
    )!

    /// URL used when the live API fails.
    static var effectiveFallbackJobsURL: URL {
        return fallbackJobsURL
    }
}
