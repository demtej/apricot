package com.apricot.shared.usecase

import com.apricot.shared.data.repository.FakeBitcoinRepository
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinInput
import com.apricot.shared.domain.BitcoinOutput
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.Satoshi
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.TransactionStatus
import com.apricot.shared.domain.error.BitcoinRepositoryError
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue

class GetAddressTransactionsTest {

    private val address = BitcoinAddress("bc1qtest")

    private fun fakeTx(id: String) = BitcoinTransaction(
        id = TransactionId(id),
        inputs = listOf(BitcoinInput(address = null, amount = Satoshi(100_000L))),
        outputs = listOf(BitcoinOutput(address = address, amount = Satoshi(99_000L))),
        fee = Satoshi(1_000L),
        status = TransactionStatus.Pending,
    )

    @Test
    fun returnsSuccessWithTransactionList() = runTest {
        val txList = listOf(fakeTx("tx1"), fakeTx("tx2"))
        val repository = FakeBitcoinRepository(addressTransactionsResult = { Result.success(txList) })
        val result = GetAddressTransactions(repository)(address)

        assertTrue(result.isSuccess)
        assertEquals(2, result.getOrThrow().size)
    }

    @Test
    fun returnsEmptyListForAddressWithNoTransactions() = runTest {
        val repository = FakeBitcoinRepository(addressTransactionsResult = { Result.success(emptyList()) })
        val result = GetAddressTransactions(repository)(address)

        assertTrue(result.isSuccess)
        assertEquals(emptyList(), result.getOrThrow())
    }

    @Test
    fun propagatesNotFoundError() = runTest {
        val repository = FakeBitcoinRepository(
            addressTransactionsResult = { Result.failure(BitcoinRepositoryError.NotFound) }
        )
        val result = GetAddressTransactions(repository)(address)

        assertTrue(result.isFailure)
        assertIs<BitcoinRepositoryError.NotFound>(result.exceptionOrNull())
    }

    @Test
    fun forwardsAddressToRepository() = runTest {
        var capturedAddress: BitcoinAddress? = null
        val repository = FakeBitcoinRepository(addressTransactionsResult = { addr ->
            capturedAddress = addr
            Result.success(emptyList())
        })
        GetAddressTransactions(repository)(address)

        assertEquals(address, capturedAddress)
    }
}
