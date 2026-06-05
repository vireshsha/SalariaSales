import Foundation

enum JobSearchFilter {
    /// Filters jobs by title or company name (case-insensitive).
    static func filter(_ jobs: [Job], query: String) -> [Job] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return jobs }

        let needle = trimmed.lowercased()
        return jobs.filter { job in
            job.title.lowercased().contains(needle)
                || job.companyName.lowercased().contains(needle)
        }
    }
}
