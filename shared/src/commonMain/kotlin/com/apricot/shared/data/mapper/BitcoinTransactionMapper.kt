package com.apricot.shared.data.mapper

import com.apricot.shared.data.dto.MempoolTransactionDto
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinInput
import com.apricot.shared.domain.BitcoinOutput
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.Satoshi
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.TransactionStatus

internal fun MempoolTransactionDto.toDomain(currentBlockHeight: Int? = null): BitcoinTransaction =
    BitcoinTransaction(
        id = TransactionId(txid),
        inputs = vin.map { it.toDomain() },
        outputs = vout.map { it.toDomain() },
        fee = Satoshi(fee),
        status = status.toDomain(currentBlockHeight),
    )

private fun MempoolTransactionDto.VinDto.toDomain(): BitcoinInput = BitcoinInput(
    address = prevout?.scriptpubkeyAddress?.let { BitcoinAddress(it) },
    amount = Satoshi(prevout?.value ?: 0L),
)

private fun MempoolTransactionDto.VoutDto.toDomain(): BitcoinOutput = BitcoinOutput(
    address = scriptpubkeyAddress?.let { BitcoinAddress(it) },
    amount = Satoshi(value),
)

private fun MempoolTransactionDto.StatusDto.toDomain(currentBlockHeight: Int?): TransactionStatus {
    val height = blockHeight
    val time = blockTime
    return if (confirmed && height != null && time != null) {
        val confirmations = if (currentBlockHeight != null) {
            (currentBlockHeight - height + 1).coerceAtLeast(1)
        } else {
            1 // fallback: block tip height unavailable
        }
        TransactionStatus.Confirmed(
            blockHeight = height,
            confirmations = confirmations,
            blockTimeEpochSeconds = time,
        )
    } else {
        TransactionStatus.Pending
    }
}
