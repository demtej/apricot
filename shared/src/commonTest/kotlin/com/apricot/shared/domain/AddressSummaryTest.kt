package com.apricot.shared.domain

import kotlin.test.Test
import kotlin.test.assertEquals

class AddressSummaryTest {

    private val address = BitcoinAddress("bc1qexampleaddress")

    @Test
    fun balanceReflectsReceivedMinusSent() {
        val summary = AddressSummary(
            address = address,
            balance = Satoshi(300_000),
            totalReceived = Satoshi(1_000_000),
            totalSent = Satoshi(700_000),
            transactionCount = 5,
        )
        // balance is stored explicitly; verify it matches the expected business relationship
        val expectedBalance = summary.totalReceived - summary.totalSent
        assertEquals(expectedBalance, summary.balance)
    }

    @Test
    fun zeroBalanceAddressHasMatchingReceivedAndSent() {
        val summary = AddressSummary(
            address = address,
            balance = Satoshi.ZERO,
            totalReceived = Satoshi(500_000),
            totalSent = Satoshi(500_000),
            transactionCount = 2,
        )
        assertEquals(Satoshi.ZERO, summary.totalReceived - summary.totalSent)
    }

    @Test
    fun freshAddressHasAllZeroAmounts() {
        val summary = AddressSummary(
            address = address,
            balance = Satoshi.ZERO,
            totalReceived = Satoshi.ZERO,
            totalSent = Satoshi.ZERO,
            transactionCount = 0,
        )
        assertEquals(Satoshi.ZERO, summary.balance)
        assertEquals(0, summary.transactionCount)
    }
}
