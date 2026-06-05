import XCTest
@testable import SalariaSales

final class SalaryFormatterTests: XCTestCase {
    func testConvertsUSDRangeToINR() {
        let result = SalaryFormatter.inrDisplay(from: "$109k - $228k")
        XCTAssertTrue(result.contains("₹"))
        XCTAssertFalse(result.contains("$"))
    }

    func testLeavesINRUnchanged() {
        let input = "₹90L - ₹1.9Cr"
        XCTAssertEqual(SalaryFormatter.inrDisplay(from: input), input)
    }

    func testEmptyStringReturnsEmpty() {
        XCTAssertEqual(SalaryFormatter.inrDisplay(from: ""), "")
    }

    func testJobDisplaySalaryConvertsAPIValues() {
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
        XCTAssertTrue(job.displaySalary.contains("₹"))
        XCTAssertFalse(job.displaySalary.contains("$"))
    }
}
