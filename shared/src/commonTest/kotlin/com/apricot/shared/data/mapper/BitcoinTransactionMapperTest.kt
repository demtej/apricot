package com.apricot.shared.data.mapper

import com.apricot.shared.data.dto.MempoolTransactionDto
import com.apricot.shared.data.fixture.MempoolFixtures
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.Satoshi
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.TransactionStatus
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull

class BitcoinTransactionMapperTest {

    private val json = Json { ignoreUnknownKeys = true }

    private fun confirmedStatusDto(blockHeight: Int = 800_000, blockTime: Long = 1_700_000_000L) =
        MempoolTransactionDto.StatusDto(confirmed = true, blockHeight = blockHeight, blockTime = blockTime)

    private fun pendingStatusDto() =
        MempoolTransactionDto.StatusDto(confirmed = false)

    private fun prevout(address: String? = "bc1qsender", value: Long = 100_000L) =
        MempoolTransactionDto.PrevoutDto(scriptpubkeyAddress = address, value = value)

    private fun vin(address: String? = "bc1qsender", value: Long = 100_000L, coinbase: Boolean = false) =
        MempoolTransactionDto.VinDto(
            prevout = if (coinbase) null else prevout(address, value),
            isCoinbase = coinbase,
        )

    private fun vout(address: String? = "bc1qrecipient", value: Long = 99_000L) =
        MempoolTransactionDto.VoutDto(scriptpubkeyAddress = address, value = value)

    private fun dto(
        txid: String = "txid001",
        inputs: List<MempoolTransactionDto.VinDto> = listOf(vin()),
        outputs: List<MempoolTransactionDto.VoutDto> = listOf(vout()),
        fee: Long = 1_000L,
        status: MempoolTransactionDto.StatusDto = confirmedStatusDto(),
    ) = MempoolTransactionDto(txid = txid, vin = inputs, vout = outputs, fee = fee, status = status)

    // --- field mapping ---

    @Test
    fun mapsTxid() {
        val tx = dto(txid = "abc123").toDomain()
        assertEquals(TransactionId("abc123"), tx.id)
    }

    @Test
    fun mapsFee() {
        val tx = dto(fee = 2_500L).toDomain()
        assertEquals(Satoshi(2_500L), tx.fee)
    }

    @Test
    fun mapsInputAddressAndAmount() {
        val tx = dto(inputs = listOf(vin(address = "bc1qsender", value = 100_000L))).toDomain()
        assertEquals(BitcoinAddress("bc1qsender"), tx.inputs[0].address)
        assertEquals(Satoshi(100_000L), tx.inputs[0].amount)
    }

    @Test
    fun mapsOutputAddressAndAmount() {
        val tx = dto(outputs = listOf(vout(address = "bc1qrecipient", value = 99_000L))).toDomain()
        assertEquals(BitcoinAddress("bc1qrecipient"), tx.outputs[0].address)
        assertEquals(Satoshi(99_000L), tx.outputs[0].amount)
    }

    @Test
    fun mapsNullInputAddressAsNull() {
        val tx = dto(inputs = listOf(vin(address = null))).toDomain()
        assertNull(tx.inputs[0].address)
    }

    @Test
    fun mapsNullOutputAddressAsNull() {
        val tx = dto(outputs = listOf(vout(address = null))).toDomain()
        assertNull(tx.outputs[0].address)
    }

    @Test
    fun mapsCoinbaseInputAsZeroAmountWithNullAddress() {
        val tx = dto(inputs = listOf(vin(coinbase = true))).toDomain()
        assertNull(tx.inputs[0].address)
        assertEquals(Satoshi.ZERO, tx.inputs[0].amount)
    }

    // --- status: pending ---

    @Test
    fun mapsPendingStatus() {
        val tx = dto(status = pendingStatusDto()).toDomain()
        assertIs<TransactionStatus.Pending>(tx.status)
    }

    // --- status: confirmations ---

    @Test
    fun confirmationsAreCalculatedFromCurrentBlockHeight() {
        // tx mined at 800_000, tip at 800_100 → 101 confirmations
        val tx = dto(status = confirmedStatusDto(blockHeight = 800_000)).toDomain(currentBlockHeight = 800_100)
        val status = assertIs<TransactionStatus.Confirmed>(tx.status)
        assertEquals(101, status.confirmations)
    }

    @Test
    fun confirmationsAreOneWhenTxIsAtChainTip() {
        val tx = dto(status = confirmedStatusDto(blockHeight = 850_000)).toDomain(currentBlockHeight = 850_000)
        val status = assertIs<TransactionStatus.Confirmed>(tx.status)
        assertEquals(1, status.confirmations)
    }

    @Test
    fun confirmationsAreClampedToOneWhenCurrentHeightBelowTxHeight() {
        // Stale tip data should never produce zero or negative confirmations
        val tx = dto(status = confirmedStatusDto(blockHeight = 850_000)).toDomain(currentBlockHeight = 849_999)
        val status = assertIs<TransactionStatus.Confirmed>(tx.status)
        assertEquals(1, status.confirmations)
    }

    @Test
    fun confirmationsFallBackToOneWhenCurrentHeightUnavailable() {
        val tx = dto(status = confirmedStatusDto(blockHeight = 800_000)).toDomain(currentBlockHeight = null)
        val status = assertIs<TransactionStatus.Confirmed>(tx.status)
        assertEquals(1, status.confirmations)
    }

    @Test
    fun mapsConfirmedStatusBlockHeightAndTime() {
        val tx = dto(status = confirmedStatusDto(blockHeight = 170, blockTime = 1_231_731_025L))
            .toDomain(currentBlockHeight = 201)
        val status = assertIs<TransactionStatus.Confirmed>(tx.status)
        assertEquals(170, status.blockHeight)
        assertEquals(1_231_731_025L, status.blockTimeEpochSeconds)
        assertEquals(32, status.confirmations) // 201 - 170 + 1
    }

    // --- JSON fixture round-trips ---

    @Test
    fun parsesConfirmedTransactionJsonFixture() {
        val parsed = json.decodeFromString<MempoolTransactionDto>(MempoolFixtures.confirmedTransactionJson)
        // tx block_height = 170; simulate current tip at 850_170 → 850_001 confirmations
        val tx = parsed.toDomain(currentBlockHeight = 850_170)

        assertEquals(TransactionId(MempoolFixtures.TXID_CONFIRMED), tx.id)
        assertEquals(Satoshi(10_000L), tx.fee)
        assertEquals(1, tx.inputs.size)
        assertEquals(2, tx.outputs.size)
        assertEquals(BitcoinAddress(MempoolFixtures.ADDRESS_FROM), tx.inputs[0].address)
        assertEquals(Satoshi(5_000_000_000L), tx.inputs[0].amount)
        val status = assertIs<TransactionStatus.Confirmed>(tx.status)
        assertEquals(170, status.blockHeight)
        assertEquals(1_231_731_025L, status.blockTimeEpochSeconds)
        assertEquals(850_001, status.confirmations) // 850_170 - 170 + 1
    }

    @Test
    fun parsesPendingTransactionJsonFixture() {
        val parsed = json.decodeFromString<MempoolTransactionDto>(MempoolFixtures.pendingTransactionJson)
        val tx = parsed.toDomain(currentBlockHeight = 850_000)

        assertEquals(TransactionId(MempoolFixtures.TXID_PENDING), tx.id)
        assertIs<TransactionStatus.Pending>(tx.status)
        assertEquals(Satoshi(10_000L), tx.fee)
    }

    @Test
    fun parsesCoinbaseTransactionJsonFixture() {
        val parsed = json.decodeFromString<MempoolTransactionDto>(MempoolFixtures.coinbaseTransactionJson)
        val tx = parsed.toDomain(currentBlockHeight = 850_001)

        assertEquals(1, tx.inputs.size)
        assertNull(tx.inputs[0].address)
        assertEquals(Satoshi.ZERO, tx.inputs[0].amount)
        val status = assertIs<TransactionStatus.Confirmed>(tx.status)
        // coinbase tx at block_height=1, tip at 850_001 → 850_001 confirmations
        assertEquals(850_001, status.confirmations)
    }
}
