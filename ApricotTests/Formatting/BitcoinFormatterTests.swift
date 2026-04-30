import XCTest
@testable import Apricot

final class BitcoinFormatterTests: XCTestCase {

    // MARK: - BTC formatting

    func test_btc_zero() {
        XCTAssertEqual(BitcoinFormatter.btc(0), "0.00 BTC")
    }

    func test_btc_oneSat() {
        XCTAssertEqual(BitcoinFormatter.btc(1), "0.00000001 BTC")
    }

    func test_btc_oneBTC() {
        XCTAssertEqual(BitcoinFormatter.btc(100_000_000), "1.00 BTC")
    }

    func test_btc_trailingZerosTrimmedAboveMinimum() {
        // 1_000_000 sats = 0.01 BTC — should trim trailing zeros, keep 2 minimum
        XCTAssertEqual(BitcoinFormatter.btc(1_000_000), "0.01 BTC")
    }

    func test_btc_allEightDecimalsKeptWhenSignificant() {
        XCTAssertEqual(BitcoinFormatter.btc(1_234_567), "0.01234567 BTC")
    }

    func test_btc_largeValue() {
        // 57.19138797 BTC = 5_719_138_797 sats
        XCTAssertEqual(BitcoinFormatter.btc(5_719_138_797), "57.19138797 BTC")
    }

    func test_btc_usesDotDecimalSeparator() {
        let result = BitcoinFormatter.btc(150_000_000)
        XCTAssertTrue(result.contains("."), "Expected dot decimal separator in BTC amount")
    }

    func test_btc_noCommaInIntegerPart() {
        // 1_000_000_000 sats = 10 BTC — no grouping separator in integer part
        let result = BitcoinFormatter.btc(1_000_000_000)
        XCTAssertEqual(result, "10.00 BTC")
        XCTAssertFalse(result.contains(","), "BTC amounts must not use comma grouping")
    }

    func test_btc_smallFeeValue() {
        // 500 sats = 0.000005 BTC
        XCTAssertEqual(BitcoinFormatter.btc(500), "0.000005 BTC")
    }

    // MARK: - Sats formatting

    func test_sats_zero() {
        XCTAssertEqual(BitcoinFormatter.sats(0), "0 sats")
    }

    func test_sats_oneSat_singular() {
        XCTAssertEqual(BitcoinFormatter.sats(1), "1 sat")
    }

    func test_sats_twoSats_plural() {
        XCTAssertEqual(BitcoinFormatter.sats(2), "2 sats")
    }

    func test_sats_largeValue_commaGrouped() {
        XCTAssertEqual(BitcoinFormatter.sats(1_234_567), "1,234,567 sats")
    }

    func test_sats_typicalFee() {
        XCTAssertEqual(BitcoinFormatter.sats(1_234), "1,234 sats")
    }

    func test_sats_millions() {
        XCTAssertEqual(BitcoinFormatter.sats(100_000_000), "100,000,000 sats")
    }

    // MARK: - Transaction ID shortening

    func test_shortTxId_longId_showsPrefixAndSuffix() {
        let txId = "a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d"
        XCTAssertEqual(BitcoinFormatter.shortTxId(txId), "a1075db5…d48d")
    }

    func test_shortTxId_shortId_returnedUnchanged() {
        XCTAssertEqual(BitcoinFormatter.shortTxId("abc123"), "abc123")
    }

    func test_shortTxId_exactlyThirteenChars_notTruncated() {
        let txId = "abcdefghijklm"
        XCTAssertEqual(BitcoinFormatter.shortTxId(txId), "abcdefghijklm")
    }

    func test_shortTxId_fourteenChars_truncated() {
        let txId = "abcdefghijklmn"
        XCTAssertEqual(BitcoinFormatter.shortTxId(txId), "abcdefgh…klmn")
    }

    func test_shortTxId_containsEllipsis() {
        let txId = "a1075db55d416d3ca199f55b6084e211"
        XCTAssertTrue(BitcoinFormatter.shortTxId(txId).contains("…"))
    }

    // MARK: - Address shortening

    func test_shortAddress_bech32_showsPrefixAndSuffix() {
        let address = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz"
        XCTAssertEqual(BitcoinFormatter.shortAddress(address), "bc1qar0s…59gtzz")
    }

    func test_shortAddress_legacyAddress_showsPrefixAndSuffix() {
        let address = "1A1zP1eP5QGefi2DMPTfTL5SLmv7Divfna"
        XCTAssertEqual(BitcoinFormatter.shortAddress(address), "1A1zP1eP…Divfna")
    }

    func test_shortAddress_shortInput_returnedUnchanged() {
        XCTAssertEqual(BitcoinFormatter.shortAddress("1A1zP1e"), "1A1zP1e")
    }

    func test_shortAddress_exactlySixteenChars_notTruncated() {
        let address = "1234567890123456"
        XCTAssertEqual(BitcoinFormatter.shortAddress(address), "1234567890123456")
    }

    func test_shortAddress_seventeenChars_truncated() {
        let address = "12345678901234567"
        XCTAssertEqual(BitcoinFormatter.shortAddress(address), "12345678…234567")
    }

    func test_shortAddress_containsEllipsis() {
        let address = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz"
        XCTAssertTrue(BitcoinFormatter.shortAddress(address).contains("…"))
    }

    // MARK: - Timestamp formatting

    func test_timestamp_returnsNonEmptyString() {
        let result = BitcoinFormatter.timestamp(epochSeconds: 1_714_435_200)
        XCTAssertFalse(result.isEmpty)
    }

    func test_timestamp_epochZero_returnsNonEmptyString() {
        let result = BitcoinFormatter.timestamp(epochSeconds: 0)
        XCTAssertFalse(result.isEmpty)
    }
}
