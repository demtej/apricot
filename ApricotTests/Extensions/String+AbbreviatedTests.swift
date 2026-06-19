@testable import Apricot
import XCTest

final class StringAbbreviatedTests: XCTestCase {
    func test_stringShorterThanMaxLength_isUnchanged() {
        XCTAssertEqual("abc".abbreviated(to: 6), "abc")
    }

    func test_stringEqualToMaxLength_isUnchanged() {
        XCTAssertEqual("abcdef".abbreviated(to: 6), "abcdef")
    }

    func test_evenMaxLength_splitsEvenly() {
        XCTAssertEqual("abcdefgh".abbreviated(to: 6), "abc…fgh")
    }

    func test_oddMaxLength_givesExtraCharacterToHead() {
        XCTAssertEqual("abcdefgh".abbreviated(to: 5), "abc…gh")
    }

    func test_realisticAddress() {
        let address = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq"
        XCTAssertEqual(address.abbreviated(to: 8), "bc1q…5mdq")
    }

    func test_maxLengthOfOne_isUnchanged() {
        XCTAssertEqual("abcdefgh".abbreviated(to: 1), "abcdefgh")
    }

    func test_maxLengthOfZero_isUnchanged() {
        XCTAssertEqual("abcdefgh".abbreviated(to: 0), "abcdefgh")
    }
}
