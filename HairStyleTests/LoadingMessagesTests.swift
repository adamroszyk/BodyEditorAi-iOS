import XCTest
@testable import HairStyle

final class LoadingMessagesTests: XCTestCase {
    func testRandomReturnsKnownMessage() {
        let message = LoadingMessages.random()
        XCTAssertTrue(LoadingMessages.all.contains(message))
    }
}
