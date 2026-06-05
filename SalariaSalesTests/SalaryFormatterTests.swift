import XCTest
@testable import SalariaSales

final class SalaryFormatterTests: XCTestCase {
    func testReturnsUSDRangeUnchanged() {
        let result = SalaryFormatter.usdDisplay(from: "$109k - $228k")
        XCTAssertEqual(result, "$109k - $228k")
        XCTAssertTrue(result.contains("$"))
        XCTAssertFalse(result.contains("₹"))
    }

    func testLeavesUSDUnchanged() {
        let input = "$90k - $110k"
        XCTAssertEqual(SalaryFormatter.usdDisplay(from: input), input)
    }

    func testEmptyStringReturnsEmpty() {
        XCTAssertEqual(SalaryFormatter.usdDisplay(from: ""), "")
    }

    func testJobDisplaySalaryUsesUSD() {
        let job = Job(
            id: 1,
            title: "Engineer",
            companyName: "Acme",
            location: "Remote",
            salaryRange: "$90k - $110k",
            description: "",
            companyLogoURL: nil,
            jobType: "Full Time",
            category: "Software",
            applyURL: nil
        )
        XCTAssertTrue(job.displaySalary.contains("$"))
        XCTAssertFalse(job.displaySalary.contains("₹"))
    }
}
