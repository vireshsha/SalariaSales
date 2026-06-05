import XCTest
@testable import SalariaSales

final class HTMLTextSanitizerTests: XCTestCase {
    func testStripsSimpleHTMLTags() {
        let result = HTMLTextSanitizer.plainText(from: "<p>Hello <strong>World</strong></p>")
        XCTAssertTrue(result.contains("Hello"))
        XCTAssertTrue(result.contains("World"))
        XCTAssertFalse(result.contains("<p>"))
    }

    func testReturnsPlainTextUnchanged() {
        let input = "Already plain text"
        XCTAssertEqual(HTMLTextSanitizer.plainText(from: input), input)
    }
}
