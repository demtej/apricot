package com.apricot.shared.domain.error

sealed class BitcoinRepositoryError(message: String? = null, cause: Throwable? = null) :
    Exception(message, cause) {

    class NetworkError(cause: Throwable) : BitcoinRepositoryError(cause.message, cause)

    data object NotFound : BitcoinRepositoryError("Resource not found")

    class DecodingError(cause: Throwable) : BitcoinRepositoryError("Failed to decode response", cause)
}
