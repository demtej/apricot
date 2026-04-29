package com.apricot.shared.domain

enum class TransactionDirection {
    /** Address received funds in this transaction. */
    INCOMING,
    /** Address spent funds in this transaction. */
    OUTGOING,
    /** Address both spent and received funds (e.g. self-send or complex tx). */
    MIXED,
}
