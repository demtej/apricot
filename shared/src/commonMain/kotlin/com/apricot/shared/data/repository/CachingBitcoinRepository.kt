package com.apricot.shared.data.repository

import com.apricot.shared.cache.Clock
import com.apricot.shared.cache.MonotonicClock
import com.apricot.shared.cache.TtlCache
import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.TransactionStatus
import com.apricot.shared.domain.repository.BitcoinRepository

class CachingBitcoinRepository(
    private val delegate: BitcoinRepository,
    clock: Clock = MonotonicClock,
    private val addressSummaryTtlMillis: Long = 60_000L,
    private val addressTransactionsTtlMillis: Long = 60_000L,
    private val confirmedTxTtlMillis: Long = 600_000L,
    private val pendingTxTtlMillis: Long = 30_000L,
) : BitcoinRepository {

    private val summaryCache = TtlCache<String, AddressSummary>(clock)
    private val transactionsCache = TtlCache<String, List<BitcoinTransaction>>(clock)
    private val txDetailCache = TtlCache<String, BitcoinTransaction>(clock)

    override suspend fun getAddressSummary(address: BitcoinAddress): Result<AddressSummary> {
        summaryCache.get(address.value)?.let { return Result.success(it) }
        return delegate.getAddressSummary(address).onSuccess { summary ->
            summaryCache.put(address.value, summary, addressSummaryTtlMillis)
        }
    }

    override suspend fun getAddressTransactions(address: BitcoinAddress): Result<List<BitcoinTransaction>> {
        transactionsCache.get(address.value)?.let { return Result.success(it) }
        return delegate.getAddressTransactions(address).onSuccess { txs ->
            transactionsCache.put(address.value, txs, addressTransactionsTtlMillis)
        }
    }

    override suspend fun getTransactionDetail(id: TransactionId): Result<BitcoinTransaction> {
        txDetailCache.get(id.value)?.let { return Result.success(it) }
        return delegate.getTransactionDetail(id).onSuccess { tx ->
            val ttl = if (tx.status is TransactionStatus.Confirmed) confirmedTxTtlMillis else pendingTxTtlMillis
            txDetailCache.put(id.value, tx, ttl)
        }
    }
}
