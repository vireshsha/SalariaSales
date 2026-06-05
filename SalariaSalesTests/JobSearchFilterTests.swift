import XCTest
@testable import SalariaSales

final class JobSearchFilterTests: XCTestCase {
    private let jobs = [
        TestFixtures.sampleJob,
        Job(
            id: 2,
            title: "Backend Engineer",
            companyName: "Beta LLC",
            location: "USA",
            salaryRange: "$83k",
            description: "",
            companyLogoURL: nil,
            jobType: "Full Time",
            category: "Software",
            applyURL: nil
        )
    ]

    func testEmptyQueryReturnsAllJobs() {
        XCTAssertEqual(JobSearchFilter.filter(jobs, query: ""), jobs)
        XCTAssertEqual(JobSearchFilter.filter(jobs, query: "   "), jobs)
    }

    func testFiltersByTitleCaseInsensitive() {
        let result = JobSearchFilter.filter(jobs, query: "mobile")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Mobile Developer")
    }

    func testFiltersByCompanyCaseInsensitive() {
        let result = JobSearchFilter.filter(jobs, query: "beta")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.companyName, "Beta LLC")
    }

    func testNoMatchReturnsEmptyArray() {
        XCTAssertTrue(JobSearchFilter.filter(jobs, query: "designer").isEmpty)
    }
}
