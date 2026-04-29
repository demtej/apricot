package com.apricot.shared.domain

import kotlin.test.Test
import kotlin.test.assertEquals

class BitcoinTransactionTest {

    private val addressA = BitcoinAddress("bc1qaddressA")
    private val addressB = BitcoinAddress("bc1qaddressB")
    private val addressC = BitcoinAddress("bc1qaddressC")

    private fun tx(
        inputs: List<BitcoinInput>,
        outputs: List<BitcoinOutput>,
        fee: Satoshi = Satoshi(1_000),
    ) = BitcoinTransaction(
        id = TransactionId("txid_test"),
        inputs = inputs,
        outputs = outputs,
        fee = fee,
        status = TransactionStatus.Pending,
    )

    @Test
    fun totalInputAmountSumsAllInputs() {
        val transaction = tx(
            inputs = listOf(
                BitcoinInput(addressA, Satoshi(100_000)),
                BitcoinInput(addressB, Satoshi(50_000)),
            ),
            outputs = listOf(BitcoinOutput(addressC, Satoshi(149_000))),
        )
        assertEquals(Satoshi(150_000), transaction.totalInputAmount)
    }

    @Test
    fun totalOutputAmountSumsAllOutputs() {
        val transaction = tx(
            inputs = listOf(BitcoinInput(addressA, Satoshi(100_000))),
            outputs = listOf(
                BitcoinOutput(addressB, Satoshi(60_000)),
                BitcoinOutput(addressC, Satoshi(39_000)),
            ),
        )
        assertEquals(Satoshi(99_000), transaction.totalOutputAmount)
    }

    @Test
    fun directionIsIncomingWhenAddressOnlyInOutputs() {
        val transaction = tx(
            inputs = listOf(BitcoinInput(addressA, Satoshi(100_000))),
            outputs = listOf(BitcoinOutput(addressB, Satoshi(99_000))),
        )
        assertEquals(TransactionDirection.INCOMING, transaction.directionRelativeTo(addressB))
    }

    @Test
    fun directionIsOutgoingWhenAddressOnlyInInputs() {
        val transaction = tx(
            inputs = listOf(BitcoinInput(addressA, Satoshi(100_000))),
            outputs = listOf(BitcoinOutput(addressB, Satoshi(99_000))),
        )
        assertEquals(TransactionDirection.OUTGOING, transaction.directionRelativeTo(addressA))
    }

    @Test
    fun directionIsMixedWhenAddressInBothInputsAndOutputs() {
        val transaction = tx(
            inputs = listOf(BitcoinInput(addressA, Satoshi(100_000))),
            outputs = listOf(
                BitcoinOutput(addressA, Satoshi(50_000)),
                BitcoinOutput(addressB, Satoshi(49_000)),
            ),
        )
        assertEquals(TransactionDirection.MIXED, transaction.directionRelativeTo(addressA))
    }

    @Test
    fun directionIsMixedWhenAddressNotInTransaction() {
        val transaction = tx(
            inputs = listOf(BitcoinInput(addressA, Satoshi(100_000))),
            outputs = listOf(BitcoinOutput(addressB, Satoshi(99_000))),
        )
        assertEquals(TransactionDirection.MIXED, transaction.directionRelativeTo(addressC))
    }

    @Test
    fun confirmedStatusReportsCorrectly() {
        val confirmed = TransactionStatus.Confirmed(
            blockHeight = 800_000,
            confirmations = 6,
            blockTimeEpochSeconds = 1_700_000_000,
        )
        assertEquals(true, confirmed.isConfirmed)
        assertEquals(false, confirmed.isPending)
    }

    @Test
    fun pendingStatusReportsCorrectly() {
        val pending = TransactionStatus.Pending
        assertEquals(false, pending.isConfirmed)
        assertEquals(true, pending.isPending)
    }
}
