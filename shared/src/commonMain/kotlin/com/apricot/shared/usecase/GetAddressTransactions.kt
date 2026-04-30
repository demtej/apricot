package com.apricot.shared.usecase

import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.repository.BitcoinRepository

class GetAddressTransactions(private val repository: BitcoinRepository) {
    suspend operator fun invoke(address: BitcoinAddress): Result<List<BitcoinTransaction>> =
        repository.getAddressTransactions(address)
}
