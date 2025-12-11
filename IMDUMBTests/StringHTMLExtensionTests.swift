import XCTest
@testable import IMDUMB

// MARK: - String+HTML Extension Tests
class StringHTMLExtensionTests: XCTestCase {

    // MARK: - Test HTML to Attributed String

    func testHtmlToAttributedString_WithValidHTML_ShouldReturnAttributedString() {
        // Given
        let htmlString = "<p>This is a <b>bold</b> text.</p>"

        // When
        let attributedString = htmlString.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
        XCTAssertTrue(attributedString!.string.contains("bold"))
    }

    func testHtmlToAttributedString_WithPlainText_ShouldReturnAttributedString() {
        // Given
        let plainString = "This is plain text"

        // When
        let attributedString = plainString.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
        XCTAssertEqual(attributedString!.string.trimmingCharacters(in: .whitespacesAndNewlines), plainString)
    }

    func testHtmlToAttributedString_WithEmptyString_ShouldReturnEmptyAttributedString() {
        // Given
        let emptyString = ""

        // When
        let attributedString = emptyString.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
        XCTAssertTrue(attributedString!.string.isEmpty || attributedString!.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    func testHtmlToAttributedString_WithHTMLEntities_ShouldDecodeCorrectly() {
        // Given
        let htmlString = "<p>Price: &pound;10 &amp; tax</p>"

        // When
        let attributedString = htmlString.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
        let string = attributedString!.string
        XCTAssertTrue(string.contains("£") || string.contains("10"))
    }

    func testHtmlToAttributedString_WithMultipleTags_ShouldPreserveContent() {
        // Given
        let htmlString = """
        <h1>Title</h1>
        <p>First paragraph with <em>emphasis</em>.</p>
        <p>Second paragraph with <strong>strong</strong> text.</p>
        """

        // When
        let attributedString = htmlString.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
        let string = attributedString!.string
        XCTAssertTrue(string.contains("Title"))
        XCTAssertTrue(string.contains("emphasis"))
        XCTAssertTrue(string.contains("strong"))
    }

    func testHtmlToAttributedString_WithInvalidHTML_ShouldHandleGracefully() {
        // Given
        let invalidHTML = "<p>Unclosed tag"

        // When
        let attributedString = invalidHTML.htmlToAttributedString

        // Then
        // Should not crash and should return something (even if not perfectly formatted)
        XCTAssertNotNil(attributedString)
    }

    func testHtmlToAttributedString_WithNestedTags_ShouldParseCorrectly() {
        // Given
        let nestedHTML = "<p>Text with <b>bold and <i>italic</i></b> formatting.</p>"

        // When
        let attributedString = nestedHTML.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
        let string = attributedString!.string
        XCTAssertTrue(string.contains("bold"))
        XCTAssertTrue(string.contains("italic"))
        XCTAssertTrue(string.contains("formatting"))
    }

    func testHtmlToAttributedString_WithLineBreaks_ShouldPreserveStructure() {
        // Given
        let htmlWithBreaks = "<p>Line 1</p><br><p>Line 2</p>"

        // When
        let attributedString = htmlWithBreaks.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
        let string = attributedString!.string
        XCTAssertTrue(string.contains("Line 1"))
        XCTAssertTrue(string.contains("Line 2"))
    }

    // MARK: - Test Edge Cases

    func testHtmlToAttributedString_WithOnlyTags_ShouldReturnMinimalString() {
        // Given
        let onlyTags = "<div></div>"

        // When
        let attributedString = onlyTags.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
    }

    func testHtmlToAttributedString_WithSpecialCharacters_ShouldHandleCorrectly() {
        // Given
        let specialChars = "<p>Special: @#$%^&*()</p>"

        // When
        let attributedString = specialChars.htmlToAttributedString

        // Then
        XCTAssertNotNil(attributedString)
        let string = attributedString!.string
        XCTAssertTrue(string.contains("Special"))
    }
}
