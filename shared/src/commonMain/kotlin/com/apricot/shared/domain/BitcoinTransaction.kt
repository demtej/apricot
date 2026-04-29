package com.apricot.shared.domain

data class BitcoinTransaction(
    val id: TransactionId,
    val inputs: List<BitcoinInput>,
    val outputs: List<BitcoinOutput>,
    val fee: Satoshi,
    val status: TransactionStatus,
) {
    val totalInputAmount: Satoshi get() = inputs.fold(Satoshi.ZERO) { acc, input -> acc + input.amount }
    val totalOutputAmount: Satoshi get() = outputs.fold(Satoshi.ZERO) { acc, output -> acc + output.amount }

    fun directionRelativeTo(address: BitcoinAddress): TransactionDirection {
        val spentFromAddress = inputs.any { it.address == address }
        val receivedByAddress = outputs.any { it.address == address }
        return when {
            spentFromAddress && receivedByAddress -> TransactionDirection.MIXED
            spentFromAddress -> TransactionDirection.OUTGOING
            receivedByAddress -> TransactionDirection.INCOMING
            else -> TransactionDirection.MIXED
        }
    }
}
