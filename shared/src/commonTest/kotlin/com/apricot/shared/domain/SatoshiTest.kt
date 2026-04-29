package com.apricot.shared.domain

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class SatoshiTest {

    @Test
    fun additionProducesCorrectSum() {
        val a = Satoshi(50_000)
        val b = Satoshi(25_000)
        assertEquals(Satoshi(75_000), a + b)
    }

    @Test
    fun subtractionProducesCorrectDifference() {
        val a = Satoshi(100_000)
        val b = Satoshi(40_000)
        assertEquals(Satoshi(60_000), a - b)
    }

    @Test
    fun unaryMinusNegatesAmount() {
        assertEquals(Satoshi(-1_000), -Satoshi(1_000))
    }

    @Test
    fun zeroConstantIsZero() {
        assertEquals(Satoshi(0), Satoshi.ZERO)
    }

    @Test
    fun toBitcoinConvertsCorrectly() {
        assertEquals(1.0, Satoshi(100_000_000).toBitcoin(), absoluteTolerance = 1e-9)
        assertEquals(0.5, Satoshi(50_000_000).toBitcoin(), absoluteTolerance = 1e-9)
        assertEquals(0.00000001, Satoshi(1).toBitcoin(), absoluteTolerance = 1e-10)
    }

    @Test
    fun fromBitcoinConvertsCorrectly() {
        assertEquals(Satoshi(100_000_000), Satoshi.fromBitcoin(1.0))
        assertEquals(Satoshi(50_000_000), Satoshi.fromBitcoin(0.5))
    }

    @Test
    fun compareToOrdersCorrectly() {
        assertTrue(Satoshi(100) > Satoshi(50))
        assertTrue(Satoshi(50) < Satoshi(100))
        assertEquals(0, Satoshi(100).compareTo(Satoshi(100)))
    }
}
