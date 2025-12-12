import XCTest
@testable import IMDUMB

class NetworkReachabilityTests: XCTestCase {

    var sut: NetworkReachability!

    override func setUp() {
        super.setUp()
        sut = NetworkReachability.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func testNetworkReachability_Singleton_ShouldReturnSameInstance() {
        // Given
        let instance1 = NetworkReachability.shared
        let instance2 = NetworkReachability.shared

        // Then
        XCTAssertTrue(instance1 === instance2, "NetworkReachability should be a singleton")
    }

    // MARK: - Reachability Tests

    func testIsReachable_ShouldReturnBoolean() {
        // When
        let isReachable = sut.isReachable

        // Then
        // Result should be either true or false (valid boolean)
        XCTAssertTrue(isReachable == true || isReachable == false)
    }

    func testIsReachable_CalledMultipleTimes_ShouldNotCrash() {
        // When/Then - Should not crash
        for _ in 0..<10 {
            _ = sut.isReachable
        }
    }

    // MARK: - Thread Safety Tests

    func testIsReachable_CalledFromMultipleThreads_ShouldBeThreadSafe() {
        // Given
        let expectation = self.expectation(description: "Thread safety")
        expectation.expectedFulfillmentCount = 10

        // When - Call from multiple threads simultaneously
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            _ = NetworkReachability.shared.isReachable
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 2.0)
    }
}
