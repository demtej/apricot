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

class GetTransactionDetailTest {

    private val txId = TransactionId("f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16")

    private val fakeTransaction = BitcoinTransaction(
        id = txId,
        inputs = listOf(
            BitcoinInput(address = BitcoinAddress("12cbQLTFMXRnSzktFkuoG3eHoMeFtpTu3S"), amount = Satoshi(5_000_000_000L))
        ),
        outputs = listOf(
            BitcoinOutput(address = BitcoinAddress("1A1zP1eP5QGefi2DMPTfTL5SLmv7Divfna"), amount = Satoshi(1_000_000_000L)),
            BitcoinOutput(address = BitcoinAddress("12cbQLTFMXRnSzktFkuoG3eHoMeFtpTu3S"), amount = Satoshi(3_999_990_000L)),
        ),
        fee = Satoshi(10_000L),
        status = TransactionStatus.Confirmed(blockHeight = 170, confirmations = 1, blockTimeEpochSeconds = 1_231_731_025L),
    )

    @Test
    fun returnsTransactionOnSuccess() = runTest {
        val repository = FakeBitcoinRepository(transactionDetailResult = { Result.success(fakeTransaction) })
        val result = GetTransactionDetail(repository)(txId)

        assertTrue(result.isSuccess)
        assertEquals(fakeTransaction, result.getOrThrow())
    }

    @Test
    fun propagatesNotFoundWhenTransactionDoesNotExist() = runTest {
        val repository = FakeBitcoinRepository(
            transactionDetailResult = { Result.failure(BitcoinRepositoryError.NotFound) }
        )
        val result = GetTransactionDetail(repository)(txId)

        assertTrue(result.isFailure)
        assertIs<BitcoinRepositoryError.NotFound>(result.exceptionOrNull())
    }

    @Test
    fun propagatesNetworkError() = runTest {
        val cause = Exception("connection refused")
        val repository = FakeBitcoinRepository(
            transactionDetailResult = { Result.failure(BitcoinRepositoryError.NetworkError(cause)) }
        )
        val result = GetTransactionDetail(repository)(txId)

        assertTrue(result.isFailure)
        assertIs<BitcoinRepositoryError.NetworkError>(result.exceptionOrNull())
    }

    @Test
    fun forwardsTransactionIdToRepository() = runTest {
        var capturedId: TransactionId? = null
        val repository = FakeBitcoinRepository(transactionDetailResult = { id ->
            capturedId = id
            Result.success(fakeTransaction)
        })
        GetTransactionDetail(repository)(txId)

        assertEquals(txId, capturedId)
    }
}
