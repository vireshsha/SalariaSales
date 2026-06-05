import Foundation
@testable import SalariaSales

enum TestFixtures {
    static let sampleJob = Job(
        id: 101,
        title: "Mobile Developer",
        companyName: "Acme Corp",
        location: "Remote",
        salaryRange: "₹75L - ₹91L",
        description: "Build iOS apps.",
        companyLogoURL: nil,
        jobType: "Full Time",
        category: "Software",
        applyURL: URL(string: "https://example.com/job")
    )

    static let remotiveJSON = """
    {
      "jobs": [
        {
          "id": 101,
          "url": "https://remotive.com/remote-jobs/example",
          "title": "Mobile Developer",
          "company_name": "Acme Corp",
          "company_logo": null,
          "category": "Software",
          "tags": [],
          "job_type": "full_time",
          "publication_date": "2026-01-01T00:00:00",
          "candidate_required_location": "Remote",
          "salary": "₹75L - ₹91L",
          "description": "Build iOS apps."
        }
      ]
    }
    """.data(using: .utf8)!
}

struct MockJobRepository: JobRepositoryProtocol {
    var result: Result<[Job], Error>

    func fetchJobs() async throws -> [Job] {
        try result.get()
    }
}

struct MockFallbackLoader: FallbackJobLoaderProtocol {
    var jobs: [Job]
    var error: Error?

    func loadJobs() async throws -> [Job] {
        if let error { throw error }
        return jobs
    }
}
