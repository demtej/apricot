package com.apricot.shared.usecase

import com.apricot.shared.data.repository.FakeBitcoinRepository
import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.Satoshi
import com.apricot.shared.domain.error.BitcoinRepositoryError
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue

class GetAddressSummaryTest {

    private val address = BitcoinAddress("bc1qtest")

    private fun summaryFor(address: BitcoinAddress) = AddressSummary(
        address = address,
        balance = Satoshi(100_000_000L),
        totalReceived = Satoshi(150_000_000L),
        totalSent = Satoshi(50_000_000L),
        transactionCount = 3,
    )

    @Test
    fun returnsSuccessWhenRepositorySucceeds() = runTest {
        val expected = summaryFor(address)
        val repository = FakeBitcoinRepository(addressSummaryResult = { Result.success(expected) })
        val result = GetAddressSummary(repository)(address)

        assertTrue(result.isSuccess)
        assertEquals(expected, result.getOrThrow())
    }

    @Test
    fun propagatesNotFoundError() = runTest {
        val repository = FakeBitcoinRepository(
            addressSummaryResult = { Result.failure(BitcoinRepositoryError.NotFound) }
        )
        val result = GetAddressSummary(repository)(address)

        assertTrue(result.isFailure)
        assertIs<BitcoinRepositoryError.NotFound>(result.exceptionOrNull())
    }

    @Test
    fun propagatesNetworkError() = runTest {
        val cause = Exception("timeout")
        val repository = FakeBitcoinRepository(
            addressSummaryResult = { Result.failure(BitcoinRepositoryError.NetworkError(cause)) }
        )
        val result = GetAddressSummary(repository)(address)

        assertTrue(result.isFailure)
        assertIs<BitcoinRepositoryError.NetworkError>(result.exceptionOrNull())
    }

    @Test
    fun forwardsAddressToRepository() = runTest {
        var capturedAddress: BitcoinAddress? = null
        val repository = FakeBitcoinRepository(addressSummaryResult = { addr ->
            capturedAddress = addr
            Result.success(summaryFor(addr))
        })
        GetAddressSummary(repository)(address)

        assertEquals(address, capturedAddress)
    }
}
