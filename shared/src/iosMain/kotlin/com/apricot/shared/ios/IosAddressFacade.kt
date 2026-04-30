package com.apricot.shared.ios

import com.apricot.shared.data.repository.CachingBitcoinRepository
import com.apricot.shared.data.repository.MempoolBitcoinRepository
import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.TransactionDirection
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.TransactionStatus
import com.apricot.shared.domain.error.BitcoinRepositoryError
import com.apricot.shared.usecase.GetAddressSummary
import com.apricot.shared.usecase.GetAddressTransactions
import com.apricot.shared.usecase.GetTransactionDetail
import kotlin.coroutines.cancellation.CancellationException

/**
 * Swift-friendly façade over the use cases.
 *
 * Accepts plain String parameters (not value-class wrappers) because Kotlin/Native
 * value classes with reference-type underlying values are exported as opaque `id`
 * in ObjC and are not directly constructible from Swift.
 *
 * Kotlin value classes with primitive underlying types (like Satoshi → Long) are
 * automatically unboxed in the generated ObjC interface, so numeric amounts are
 * exposed as Int64 without further wrapping.
 */
class IosAddressFacade(
    private val getSummary: GetAddressSummary,
    private val getTransactions: GetAddressTransactions,
    private val getDetail: GetTransactionDetail,
) {
    @Throws(BitcoinRepositoryError::class, CancellationException::class)
    suspend fun getAddressSummary(addressString: String): AddressSummary =
        getSummary(BitcoinAddress(addressString)).getOrThrow()

    @Throws(BitcoinRepositoryError::class, CancellationException::class)
    suspend fun getAddressTransactions(addressString: String): List<BitcoinTransaction> =
        getTransactions(BitcoinAddress(addressString)).getOrThrow()

    fun transactionId(tx: BitcoinTransaction): String = tx.id.value

    /** Net satoshi effect of `tx` on `forAddressString` (positive = received, negative = spent). */
    fun transactionNetAmountSats(tx: BitcoinTransaction, forAddressString: String): Long {
        val address = BitcoinAddress(forAddressString)
        val received = tx.outputs
            .filter { it.address?.value == address.value }
            .sumOf { it.amount.amount }
        val spent = tx.inputs
            .filter { it.address?.value == address.value }
            .sumOf { it.amount.amount }
        return received - spent
    }

    /** Returns "incoming", "outgoing", or "mixed". */
    fun transactionDirection(tx: BitcoinTransaction, forAddressString: String): String =
        when (tx.directionRelativeTo(BitcoinAddress(forAddressString))) {
            TransactionDirection.INCOMING -> "incoming"
            TransactionDirection.OUTGOING -> "outgoing"
            TransactionDirection.MIXED -> "mixed"
        }

    fun isTransactionConfirmed(tx: BitcoinTransaction): Boolean = tx.status.isConfirmed

    // MARK: - Transaction detail

    @Throws(BitcoinRepositoryError::class, CancellationException::class)
    suspend fun getTransactionDetail(txId: String): BitcoinTransaction =
        getDetail(TransactionId(txId)).getOrThrow()

    fun transactionFeeSats(tx: BitcoinTransaction): Long = tx.fee.amount

    /** Returns -1 if the transaction is not confirmed. */
    fun transactionBlockHeight(tx: BitcoinTransaction): Int =
        (tx.status as? TransactionStatus.Confirmed)?.blockHeight ?: -1

    /** Returns -1 if the transaction is not confirmed. */
    fun transactionConfirmations(tx: BitcoinTransaction): Int =
        (tx.status as? TransactionStatus.Confirmed)?.confirmations ?: -1

    /** Returns -1 if the transaction is not confirmed. */
    fun transactionBlockTimeEpochSeconds(tx: BitcoinTransaction): Long =
        (tx.status as? TransactionStatus.Confirmed)?.blockTimeEpochSeconds ?: -1L

    fun inputCount(tx: BitcoinTransaction): Int = tx.inputs.size
    fun inputAddressAt(tx: BitcoinTransaction, index: Int): String? = tx.inputs[index].address?.value
    fun inputAmountSatsAt(tx: BitcoinTransaction, index: Int): Long = tx.inputs[index].amount.amount

    fun outputCount(tx: BitcoinTransaction): Int = tx.outputs.size
    fun outputAddressAt(tx: BitcoinTransaction, index: Int): String? = tx.outputs[index].address?.value
    fun outputAmountSatsAt(tx: BitcoinTransaction, index: Int): Long = tx.outputs[index].amount.amount

    companion object {
        fun create(): IosAddressFacade {
            val repo = CachingBitcoinRepository(MempoolBitcoinRepository.create())
            return IosAddressFacade(
                getSummary = GetAddressSummary(repo),
                getTransactions = GetAddressTransactions(repo),
                getDetail = GetTransactionDetail(repo),
            )
        }
    }
}
