import Foundation

/// Remote and local URLs for job data sources.
enum JobEndpoints {
    /// Live Remotive public API (primary source).
    static let liveJobsURL = URL(string: "https://remotive.com/api/remote-jobs")!

    /// Static JSON mirror of `jobs_fallback.json` (same Remotive schema).
    ///
    /// - **Local dev:** run `python3 scripts/serve_jobs_fallback.py`, then use `localFallbackJobsURL`.
    /// - **Production:** hosted on GitHub at https://github.com/vireshsha/SalariaSales
    static let fallbackJobsURL = URL(
        string: "https://raw.githubusercontent.com/vireshsha/SalariaSales/main/SalariaSales/Resources/jobs_fallback.json"
    )!

    /// Serves `jobs_fallback.json` from your machine (see `scripts/serve_jobs_fallback.py`).
    static let localFallbackJobsURL = URL(string: "http://127.0.0.1:8080/jobs_fallback.json")!

    /// URL used when the live API fails. Prefers local server in DEBUG when reachable.
    static var effectiveFallbackJobsURL: URL {
        #if DEBUG
        if ProcessInfo.processInfo.environment["USE_LOCAL_JOBS_FALLBACK"] == "1" {
            return localFallbackJobsURL
        }
        #endif
        return fallbackJobsURL
    }
}
