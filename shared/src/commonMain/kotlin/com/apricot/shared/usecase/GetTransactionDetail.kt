package com.apricot.shared.usecase

import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.repository.BitcoinRepository

class GetTransactionDetail(private val repository: BitcoinRepository) {
    suspend operator fun invoke(id: TransactionId): Result<BitcoinTransaction> =
        repository.getTransactionDetail(id)
}
