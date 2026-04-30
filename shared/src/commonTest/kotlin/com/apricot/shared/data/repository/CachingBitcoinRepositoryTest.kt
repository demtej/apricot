package com.apricot.shared.data.repository

import com.apricot.shared.cache.ManualClock
import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinInput
import com.apricot.shared.domain.BitcoinOutput
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.Satoshi
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.TransactionStatus
import com.apricot.shared.domain.error.BitcoinRepositoryError
import com.apricot.shared.domain.repository.BitcoinRepository
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class CachingBitcoinRepositoryTest {

    private val address = BitcoinAddress("bc1qtest")
    private val txId = TransactionId("abc123")

    private val fakeSummary = AddressSummary(
        address = address,
        balance = Satoshi(100_000L),
        totalReceived = Satoshi(200_000L),
        totalSent = Satoshi(100_000L),
        transactionCount = 2,
    )

    private val confirmedTx = BitcoinTransaction(
        id = txId,
        inputs = listOf(BitcoinInput(address = null, amount = Satoshi(10_000L))),
        outputs = listOf(BitcoinOutput(address = null, amount = Satoshi(9_000L))),
        fee = Satoshi(1_000L),
        status = TransactionStatus.Confirmed(blockHeight = 800_000, confirmations = 6, blockTimeEpochSeconds = 1_700_000_000L),
    )

    private val pendingTx = confirmedTx.copy(status = TransactionStatus.Pending)

    private val clock = ManualClock()

    private fun makeCaching(delegate: BitcoinRepository) = CachingBitcoinRepository(
        delegate = delegate,
        clock = clock,
        addressSummaryTtlMillis = 60_000L,
        addressTransactionsTtlMillis = 60_000L,
        confirmedTxTtlMillis = 600_000L,
        pendingTxTtlMillis = 30_000L,
    )

    // --- address summary ---

    @Test
    fun addressSummaryMissCallsDelegate() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            addressSummaryResult = { calls++; Result.success(fakeSummary) }
        ))
        repo.getAddressSummary(address)
        assertEquals(1, calls)
    }

    @Test
    fun addressSummaryHitDoesNotCallDelegate() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            addressSummaryResult = { calls++; Result.success(fakeSummary) }
        ))
        repo.getAddressSummary(address)
        repo.getAddressSummary(address)
        assertEquals(1, calls)
    }

    @Test
    fun addressSummaryExpiredCallsDelegateAgain() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            addressSummaryResult = { calls++; Result.success(fakeSummary) }
        ))
        repo.getAddressSummary(address)
        clock.advanceBy(60_000L)
        repo.getAddressSummary(address)
        assertEquals(2, calls)
    }

    @Test
    fun addressSummaryErrorNotCached() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            addressSummaryResult = { calls++; Result.failure(BitcoinRepositoryError.NotFound) }
        ))
        repo.getAddressSummary(address)
        repo.getAddressSummary(address)
        assertEquals(2, calls)
    }

    // --- address transactions ---

    @Test
    fun addressTransactionsMissCallsDelegate() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            addressTransactionsResult = { calls++; Result.success(listOf(confirmedTx)) }
        ))
        repo.getAddressTransactions(address)
        assertEquals(1, calls)
    }

    @Test
    fun addressTransactionsHitDoesNotCallDelegate() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            addressTransactionsResult = { calls++; Result.success(listOf(confirmedTx)) }
        ))
        repo.getAddressTransactions(address)
        repo.getAddressTransactions(address)
        assertEquals(1, calls)
    }

    @Test
    fun addressTransactionsExpiredCallsDelegateAgain() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            addressTransactionsResult = { calls++; Result.success(listOf(confirmedTx)) }
        ))
        repo.getAddressTransactions(address)
        clock.advanceBy(60_000L)
        repo.getAddressTransactions(address)
        assertEquals(2, calls)
    }

    @Test
    fun addressTransactionsErrorNotCached() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            addressTransactionsResult = { calls++; Result.failure(BitcoinRepositoryError.NotFound) }
        ))
        repo.getAddressTransactions(address)
        repo.getAddressTransactions(address)
        assertEquals(2, calls)
    }

    // --- transaction detail ---

    @Test
    fun transactionDetailMissCallsDelegate() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            transactionDetailResult = { calls++; Result.success(confirmedTx) }
        ))
        repo.getTransactionDetail(txId)
        assertEquals(1, calls)
    }

    @Test
    fun transactionDetailHitDoesNotCallDelegate() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            transactionDetailResult = { calls++; Result.success(confirmedTx) }
        ))
        repo.getTransactionDetail(txId)
        repo.getTransactionDetail(txId)
        assertEquals(1, calls)
    }

    @Test
    fun confirmedTransactionDetailUsesLongTtl() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            transactionDetailResult = { calls++; Result.success(confirmedTx) }
        ))
        repo.getTransactionDetail(txId)
        clock.advanceBy(599_999L)
        repo.getTransactionDetail(txId)
        assertEquals(1, calls)
    }

    @Test
    fun confirmedTransactionDetailExpiredAfterLongTtl() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            transactionDetailResult = { calls++; Result.success(confirmedTx) }
        ))
        repo.getTransactionDetail(txId)
        clock.advanceBy(600_000L)
        repo.getTransactionDetail(txId)
        assertEquals(2, calls)
    }

    @Test
    fun pendingTransactionDetailUsesShortTtl() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            transactionDetailResult = { calls++; Result.success(pendingTx) }
        ))
        repo.getTransactionDetail(txId)
        clock.advanceBy(29_999L)
        repo.getTransactionDetail(txId)
        assertEquals(1, calls)
    }

    @Test
    fun pendingTransactionDetailExpiredAfterShortTtl() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            transactionDetailResult = { calls++; Result.success(pendingTx) }
        ))
        repo.getTransactionDetail(txId)
        clock.advanceBy(30_000L)
        repo.getTransactionDetail(txId)
        assertEquals(2, calls)
    }

    @Test
    fun transactionDetailErrorNotCached() = runTest {
        var calls = 0
        val repo = makeCaching(FakeBitcoinRepository(
            transactionDetailResult = { calls++; Result.failure(BitcoinRepositoryError.NotFound) }
        ))
        repo.getTransactionDetail(txId)
        repo.getTransactionDetail(txId)
        assertEquals(2, calls)
    }

    @Test
    fun successResultIsReturnedFromCache() = runTest {
        val repo = makeCaching(FakeBitcoinRepository(
            addressSummaryResult = { Result.success(fakeSummary) }
        ))
        repo.getAddressSummary(address)
        val cached = repo.getAddressSummary(address)
        assertTrue(cached.isSuccess)
        assertEquals(fakeSummary, cached.getOrThrow())
    }
}
