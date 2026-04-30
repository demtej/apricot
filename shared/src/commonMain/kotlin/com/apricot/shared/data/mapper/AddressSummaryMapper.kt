package com.apricot.shared.data.mapper

import com.apricot.shared.data.dto.MempoolAddressDto
import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.Satoshi

internal fun MempoolAddressDto.toDomain(): AddressSummary {
    val totalReceived = Satoshi(chainStats.fundedTxoSum)
    val totalSent = Satoshi(chainStats.spentTxoSum)
    return AddressSummary(
        address = BitcoinAddress(address),
        balance = totalReceived - totalSent,
        totalReceived = totalReceived,
        totalSent = totalSent,
        transactionCount = chainStats.txCount,
    )
}
