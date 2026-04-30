package com.apricot.shared.data.repository

import com.apricot.shared.data.dto.MempoolAddressDto
import com.apricot.shared.data.dto.MempoolTransactionDto
import com.apricot.shared.data.mapper.toDomain
import com.apricot.shared.domain.AddressSummary
import com.apricot.shared.domain.BitcoinAddress
import com.apricot.shared.domain.BitcoinTransaction
import com.apricot.shared.domain.TransactionId
import com.apricot.shared.domain.error.BitcoinRepositoryError
import com.apricot.shared.domain.repository.BitcoinRepository
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.client.statement.bodyAsText
import io.ktor.http.HttpStatusCode
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.serialization.json.Json

class MempoolBitcoinRepository(
    private val httpClient: HttpClient,
    private val baseUrl: String = BASE_URL,
) : BitcoinRepository {

    override suspend fun getAddressSummary(address: BitcoinAddress): Result<AddressSummary> =
        get<MempoolAddressDto>("$baseUrl/api/address/${address.value}")
            .mapCatching { it.toDomain() }

    override suspend fun getAddressTransactions(address: BitcoinAddress): Result<List<BitcoinTransaction>> =
        coroutineScope {
            val listDeferred = async { get<List<MempoolTransactionDto>>("$baseUrl/api/address/${address.value}/txs") }
            val tipDeferred = async { fetchBlockTipHeight() }

            listDeferred.await().mapCatching { list ->
                val currentHeight = tipDeferred.await().getOrNull()
                list.map { it.toDomain(currentHeight) }
            }
        }

    override suspend fun getTransactionDetail(id: TransactionId): Result<BitcoinTransaction> =
        coroutineScope {
            val txDeferred = async { get<MempoolTransactionDto>("$baseUrl/api/tx/${id.value}") }
            val tipDeferred = async { fetchBlockTipHeight() }

            txDeferred.await().mapCatching { dto ->
                val currentHeight = tipDeferred.await().getOrNull()
                dto.toDomain(currentHeight)
            }
        }

    private suspend fun fetchBlockTipHeight(): Result<Int> {
        return try {
            val response = httpClient.get("$baseUrl/api/blocks/tip/height")
            when (response.status) {
                HttpStatusCode.OK -> try {
                    Result.success(response.bodyAsText().trim().toInt())
                } catch (e: Exception) {
                    Result.failure(BitcoinRepositoryError.DecodingError(e))
                }
                else -> Result.failure(
                    BitcoinRepositoryError.NetworkError(Exception("HTTP ${response.status.value}"))
                )
            }
        } catch (e: Exception) {
            Result.failure(BitcoinRepositoryError.NetworkError(e))
        }
    }

    private suspend inline fun <reified T> get(url: String): Result<T> {
        return try {
            val response = httpClient.get(url)
            when (response.status) {
                HttpStatusCode.OK -> try {
                    Result.success(response.body<T>())
                } catch (e: Exception) {
                    Result.failure(BitcoinRepositoryError.DecodingError(e))
                }
                HttpStatusCode.NotFound -> Result.failure(BitcoinRepositoryError.NotFound)
                else -> Result.failure(
                    BitcoinRepositoryError.NetworkError(Exception("HTTP ${response.status.value}"))
                )
            }
        } catch (e: Exception) {
            Result.failure(BitcoinRepositoryError.NetworkError(e))
        }
    }

    companion object {
        private const val BASE_URL = "https://mempool.space"

        fun create(baseUrl: String = BASE_URL): MempoolBitcoinRepository =
            MempoolBitcoinRepository(
                httpClient = HttpClient {
                    install(ContentNegotiation) {
                        json(Json {
                            ignoreUnknownKeys = true
                            isLenient = true
                        })
                    }
                    install(HttpTimeout) {
                        requestTimeoutMillis = 15_000
                        connectTimeoutMillis = 10_000
                        socketTimeoutMillis = 15_000
                    }
                },
                baseUrl = baseUrl,
            )
    }
}
