package com.apricot.shared.domain

value class Satoshi(val amount: Long) : Comparable<Satoshi> {

    operator fun plus(other: Satoshi): Satoshi = Satoshi(amount + other.amount)
    operator fun minus(other: Satoshi): Satoshi = Satoshi(amount - other.amount)
    operator fun unaryMinus(): Satoshi = Satoshi(-amount)

    override fun compareTo(other: Satoshi): Int = amount.compareTo(other.amount)

    fun toBitcoin(): Double = amount / 100_000_000.0

    override fun toString(): String = "$amount sat"

    companion object {
        val ZERO = Satoshi(0)

        fun fromBitcoin(bitcoin: Double): Satoshi = Satoshi((bitcoin * 100_000_000).toLong())
    }
}
