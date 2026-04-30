package com.apricot.shared.data.mapper

import com.apricot.shared.data.dto.MempoolAddressDto
import com.apricot.shared.data.fixture.MempoolFixtures
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.Satoshi
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals

class AddressSummaryMapperTest {

    private val json = Json { ignoreUnknownKeys = true }

    private fun dto(
        address: String = MempoolFixtures.ADDRESS,
        fundedTxoSum: Long = 150_000_000L,
        spentTxoSum: Long = 50_000_000L,
        txCount: Int = 3,
    ) = MempoolAddressDto(
        address = address,
        chainStats = MempoolAddressDto.ChainStatsDto(
            fundedTxoCount = 3,
            fundedTxoSum = fundedTxoSum,
            spentTxoCount = 1,
            spentTxoSum = spentTxoSum,
            txCount = txCount,
        ),
        mempoolStats = MempoolAddressDto.MempoolStatsDto(
            fundedTxoCount = 0,
            fundedTxoSum = 0,
            spentTxoCount = 0,
            spentTxoSum = 0,
            txCount = 0,
        ),
    )

    @Test
    fun mapsAddressCorrectly() {
        val summary = dto().toDomain()
        assertEquals(BitcoinAddress(MempoolFixtures.ADDRESS), summary.address)
    }

    @Test
    fun mapsBalanceAsReceivedMinusSent() {
        val summary = dto(fundedTxoSum = 150_000_000L, spentTxoSum = 50_000_000L).toDomain()
        assertEquals(Satoshi(100_000_000L), summary.balance)
    }

    @Test
    fun mapsTotalReceivedFromFundedTxoSum() {
        val summary = dto(fundedTxoSum = 150_000_000L).toDomain()
        assertEquals(Satoshi(150_000_000L), summary.totalReceived)
    }

    @Test
    fun mapsTotalSentFromSpentTxoSum() {
        val summary = dto(spentTxoSum = 50_000_000L).toDomain()
        assertEquals(Satoshi(50_000_000L), summary.totalSent)
    }

    @Test
    fun mapsTransactionCountFromChainStats() {
        val summary = dto(txCount = 7).toDomain()
        assertEquals(7, summary.transactionCount)
    }

    @Test
    fun balanceIsZeroWhenReceivedEqualsSent() {
        val summary = dto(fundedTxoSum = 500_000L, spentTxoSum = 500_000L).toDomain()
        assertEquals(Satoshi.ZERO, summary.balance)
    }

    @Test
    fun parsesAddressJsonFixtureCorrectly() {
        val parsed = json.decodeFromString<MempoolAddressDto>(MempoolFixtures.addressJson)
        val summary = parsed.toDomain()

        assertEquals(BitcoinAddress(MempoolFixtures.ADDRESS), summary.address)
        assertEquals(Satoshi(150_000_000L), summary.totalReceived)
        assertEquals(Satoshi(50_000_000L), summary.totalSent)
        assertEquals(Satoshi(100_000_000L), summary.balance)
        assertEquals(3, summary.transactionCount)
    }
}
