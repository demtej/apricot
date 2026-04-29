package com.apricot.shared.domain

data class AddressSummary(
    val address: BitcoinAddress,
    val balance: Satoshi,
    val totalReceived: Satoshi,
    val totalSent: Satoshi,
    val transactionCount: Int,
)
