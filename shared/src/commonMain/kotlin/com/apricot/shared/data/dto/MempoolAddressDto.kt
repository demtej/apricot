package com.apricot.shared.data.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
internal data class MempoolAddressDto(
    val address: String,
    @SerialName("chain_stats") val chainStats: ChainStatsDto,
    @SerialName("mempool_stats") val mempoolStats: MempoolStatsDto,
) {
    @Serializable
    internal data class ChainStatsDto(
        @SerialName("funded_txo_count") val fundedTxoCount: Int,
        @SerialName("funded_txo_sum") val fundedTxoSum: Long,
        @SerialName("spent_txo_count") val spentTxoCount: Int,
        @SerialName("spent_txo_sum") val spentTxoSum: Long,
        @SerialName("tx_count") val txCount: Int,
    )

    @Serializable
    internal data class MempoolStatsDto(
        @SerialName("funded_txo_count") val fundedTxoCount: Int,
        @SerialName("funded_txo_sum") val fundedTxoSum: Long,
        @SerialName("spent_txo_count") val spentTxoCount: Int,
        @SerialName("spent_txo_sum") val spentTxoSum: Long,
        @SerialName("tx_count") val txCount: Int,
    )
}
