package com.apricot.shared.data.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
internal data class MempoolTransactionDto(
    val txid: String,
    val vin: List<VinDto>,
    val vout: List<VoutDto>,
    val fee: Long,
    val status: StatusDto,
) {
    @Serializable
    internal data class VinDto(
        val prevout: PrevoutDto? = null,
        @SerialName("is_coinbase") val isCoinbase: Boolean = false,
    )

    @Serializable
    internal data class PrevoutDto(
        @SerialName("scriptpubkey_address") val scriptpubkeyAddress: String? = null,
        val value: Long,
    )

    @Serializable
    internal data class VoutDto(
        @SerialName("scriptpubkey_address") val scriptpubkeyAddress: String? = null,
        val value: Long,
    )

    @Serializable
    internal data class StatusDto(
        val confirmed: Boolean,
        @SerialName("block_height") val blockHeight: Int? = null,
        @SerialName("block_time") val blockTime: Long? = null,
    )
}
