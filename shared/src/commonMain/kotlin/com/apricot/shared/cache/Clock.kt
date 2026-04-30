package com.apricot.shared.cache

import kotlin.time.TimeSource

fun interface Clock {
    fun nowMillis(): Long
}

internal object MonotonicClock : Clock {
    private val start = TimeSource.Monotonic.markNow()
    override fun nowMillis(): Long = start.elapsedNow().inWholeMilliseconds
}
