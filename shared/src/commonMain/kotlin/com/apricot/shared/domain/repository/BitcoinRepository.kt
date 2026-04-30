package com.apricot.shared.domain.repository

import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.TransactionId

interface BitcoinRepository {
    suspend fun getAddressSummary(address: BitcoinAddress): Result<AddressSummary>
    suspend fun getAddressTransactions(address: BitcoinAddress): Result<List<BitcoinTransaction>>
    suspend fun getTransactionDetail(id: TransactionId): Result<BitcoinTransaction>
}
