package com.apricot.shared.usecase

import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.repository.BitcoinRepository

class GetAddressSummary(private val repository: BitcoinRepository) {
    suspend operator fun invoke(address: BitcoinAddress): Result<AddressSummary> =
        repository.getAddressSummary(address)
}
