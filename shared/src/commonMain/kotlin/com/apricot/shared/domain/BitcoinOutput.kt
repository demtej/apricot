package com.apricot.shared.domain

data class BitcoinOutput(
    val address: BitcoinAddress?,
    val amount: Satoshi,
)
