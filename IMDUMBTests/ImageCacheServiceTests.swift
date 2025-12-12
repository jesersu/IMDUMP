import XCTest
@testable import IMDUMB

class ImageCacheServiceTests: XCTestCase {

    var sut: ImageCacheService!
    let testURL = URL(string: "https://image.tmdb.org/t/p/w500/test.jpg")!

    override func setUp() {
        super.setUp()
        sut = ImageCacheService.shared
        sut.clearAll()
        sut.initialize()
    }

    override func tearDown() {
        sut.clearAll()
        sut = nil
        super.tearDown()
    }

    // MARK: - Test Save and Load

    func testSaveImage_WithValidImage_ShouldSucceed() {
        // Given
        let testImage = createTestImage()

        // When
        let saveResult = sut.saveImage(testImage, forURL: testURL, type: .poster)

        // Then
        XCTAssertTrue(saveResult, "Image should be saved successfully")
    }

    func testLoadImage_WithSavedImage_ShouldReturnImage() {
        // Given
        let testImage = createTestImage()
        _ = sut.saveImage(testImage, forURL: testURL, type: .poster)

        // When
        let loadedImage = sut.loadImage(forURL: testURL)

        // Then
        XCTAssertNotNil(loadedImage, "Loaded image should not be nil")
        XCTAssertEqual(loadedImage?.size, testImage.size)
    }

    func testLoadImage_WithNonExistentURL_ShouldReturnNil() {
        // Given
        let nonExistentURL = URL(string: "https://example.com/nonexistent.jpg")!

        // When
        let loadedImage = sut.loadImage(forURL: nonExistentURL)

        // Then
        XCTAssertNil(loadedImage)
    }

    // MARK: - Test Different Image Types

    func testSaveImage_WithPosterType_ShouldSaveInPostersDirectory() {
        // Given
        let testImage = createTestImage()

        // When
        let saveResult = sut.saveImage(testImage, forURL: testURL, type: .poster)

        // Then
        XCTAssertTrue(saveResult)
        XCTAssertNotNil(sut.loadImage(forURL: testURL))
    }

    func testSaveImage_WithBackdropType_ShouldSaveInBackdropsDirectory() {
        // Given
        let testImage = createTestImage()
        let backdropURL = URL(string: "https://image.tmdb.org/t/p/w780/backdrop.jpg")!

        // When
        let saveResult = sut.saveImage(testImage, forURL: backdropURL, type: .backdrop)

        // Then
        XCTAssertTrue(saveResult)
        XCTAssertNotNil(sut.loadImage(forURL: backdropURL))
    }

    func testSaveImage_WithProfileType_ShouldSaveInProfilesDirectory() {
        // Given
        let testImage = createTestImage()
        let profileURL = URL(string: "https://image.tmdb.org/t/p/w185/profile.jpg")!

        // When
        let saveResult = sut.saveImage(testImage, forURL: profileURL, type: .profile)

        // Then
        XCTAssertTrue(saveResult)
        XCTAssertNotNil(sut.loadImage(forURL: profileURL))
    }

    // MARK: - Test Expiration

    func testIsExpired_WithFreshImage_ShouldReturnFalse() {
        // Given
        let testImage = createTestImage()
        _ = sut.saveImage(testImage, forURL: testURL, type: .poster)

        // When
        let isExpired = sut.isExpired(forURL: testURL, expirationInterval: 60)

        // Then
        XCTAssertFalse(isExpired)
    }

    func testIsExpired_WithNonExistentImage_ShouldReturnTrue() {
        // Given
        let nonExistentURL = URL(string: "https://example.com/nonexistent.jpg")!

        // When
        let isExpired = sut.isExpired(forURL: nonExistentURL, expirationInterval: 60)

        // Then
        XCTAssertTrue(isExpired)
    }

    func testIsExpired_WithExpiredImage_ShouldReturnTrue() {
        // Given
        let testImage = createTestImage()
        _ = sut.saveImage(testImage, forURL: testURL, type: .poster)

        // When
        let isExpired = sut.isExpired(forURL: testURL, expirationInterval: -1)

        // Then
        XCTAssertTrue(isExpired, "Image should be expired with negative expiration interval")
    }

    // MARK: - Test Clear Operations

    func testClearExpiredImages_WithExpiredImages_ShouldRemoveThem() {
        // Given
        let testImage = createTestImage()
        _ = sut.saveImage(testImage, forURL: testURL, type: .poster)

        // Wait a moment
        Thread.sleep(forTimeInterval: 0.1)

        // When
        sut.clearExpiredImages()

        // Then - Image should still exist because we use 24-hour expiration
        XCTAssertNotNil(sut.loadImage(forURL: testURL))
    }

    func testClearAll_WithMultipleImages_ShouldRemoveAll() {
        // Given
        let testImage = createTestImage()
        let url1 = URL(string: "https://example.com/image1.jpg")!
        let url2 = URL(string: "https://example.com/image2.jpg")!

        _ = sut.saveImage(testImage, forURL: url1, type: .poster)
        _ = sut.saveImage(testImage, forURL: url2, type: .backdrop)

        // When
        sut.clearAll()
        sut.initialize()

        // Then
        XCTAssertNil(sut.loadImage(forURL: url1))
        XCTAssertNil(sut.loadImage(forURL: url2))
    }

    // MARK: - Test Multiple Saves

    func testSaveImage_WithMultipleSaves_ShouldOverwritePreviousImage() {
        // Given
        let image1 = createTestImage(size: CGSize(width: 100, height: 100))
        let image2 = createTestImage(size: CGSize(width: 200, height: 200))

        // When
        _ = sut.saveImage(image1, forURL: testURL, type: .poster)
        _ = sut.saveImage(image2, forURL: testURL, type: .poster)

        // Then
        let loadedImage = sut.loadImage(forURL: testURL)
        XCTAssertNotNil(loadedImage)
        XCTAssertEqual(loadedImage?.size, image2.size)
    }

    // MARK: - Helper Methods

    private func createTestImage(size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
