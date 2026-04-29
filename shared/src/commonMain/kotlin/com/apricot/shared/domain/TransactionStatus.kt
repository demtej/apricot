package com.apricot.shared.domain

sealed class TransactionStatus {
    data object Pending : TransactionStatus()

    data class Confirmed(
        val blockHeight: Int,
        val confirmations: Int,
        val blockTimeEpochSeconds: Long,
    ) : TransactionStatus()

    val isConfirmed: Boolean get() = this is Confirmed
    val isPending: Boolean get() = this is Pending
}
