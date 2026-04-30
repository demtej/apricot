package com.apricot.shared.cache

internal class ManualClock(private var nowMillis: Long = 0L) : Clock {
    override fun nowMillis(): Long = nowMillis
    fun advanceBy(millis: Long) { nowMillis += millis }
}
