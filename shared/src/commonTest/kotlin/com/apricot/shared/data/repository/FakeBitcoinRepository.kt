package com.apricot.shared.data.repository

import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.repository.BitcoinRepository

class FakeBitcoinRepository(
    private val addressSummaryResult: (BitcoinAddress) -> Result<AddressSummary> = {
        Result.failure(NotImplementedError())
    },
    private val addressTransactionsResult: (BitcoinAddress) -> Result<List<BitcoinTransaction>> = {
        Result.failure(NotImplementedError())
    },
    private val transactionDetailResult: (TransactionId) -> Result<BitcoinTransaction> = {
        Result.failure(NotImplementedError())
    },
) : BitcoinRepository {

    override suspend fun getAddressSummary(address: BitcoinAddress): Result<AddressSummary> =
        addressSummaryResult(address)

    override suspend fun getAddressTransactions(address: BitcoinAddress): Result<List<BitcoinTransaction>> =
        addressTransactionsResult(address)

    override suspend fun getTransactionDetail(id: TransactionId): Result<BitcoinTransaction> =
        transactionDetailResult(id)
}
