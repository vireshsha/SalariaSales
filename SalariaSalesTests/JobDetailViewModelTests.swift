import XCTest
@testable import SalariaSales

@MainActor
final class JobDetailViewModelTests: XCTestCase {
    func testCompanySummaryJoinsMetadata() {
        let viewModel = JobDetailViewModel(job: TestFixtures.sampleJob)
        XCTAssertEqual(viewModel.companySummary, "Acme Corp · Software · Full Time")
    }

    func testDisplaySalaryFallbackWhenMissing() {
        let job = Job(
            id: 1,
            title: "Engineer",
            companyName: "Acme",
            location: "Remote",
            salaryRange: "",
            description: "Desc",
            companyLogoURL: nil,
            jobType: "Full Time",
            category: "Software",
            applyURL: nil
        )
        XCTAssertEqual(job.displaySalary, "Salary not disclosed")
    }
}
