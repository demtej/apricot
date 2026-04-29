package com.apricot.shared.domain

data class BitcoinInput(
    val address: BitcoinAddress?,
    val amount: Satoshi,
)
