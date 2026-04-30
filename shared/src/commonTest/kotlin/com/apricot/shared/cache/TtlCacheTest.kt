package com.apricot.shared.cache

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class TtlCacheTest {

    private val clock = ManualClock()
    private val cache = TtlCache<String, String>(clock)

    @Test
    fun returnNullOnMiss() {
        assertNull(cache.get("key"))
    }

    @Test
    fun returnValueBeforeExpiration() {
        cache.put("key", "value", ttlMillis = 1_000L)
        clock.advanceBy(999L)
        assertEquals("value", cache.get("key"))
    }

    @Test
    fun returnNullAfterExpiration() {
        cache.put("key", "value", ttlMillis = 1_000L)
        clock.advanceBy(1_000L)
        assertNull(cache.get("key"))
    }

    @Test
    fun overwriteExistingEntry() {
        cache.put("key", "first", ttlMillis = 1_000L)
        cache.put("key", "second", ttlMillis = 1_000L)
        assertEquals("second", cache.get("key"))
    }

    @Test
    fun independentEntriesDoNotInterfere() {
        cache.put("a", "valueA", ttlMillis = 500L)
        cache.put("b", "valueB", ttlMillis = 2_000L)
        clock.advanceBy(600L)
        assertNull(cache.get("a"))
        assertEquals("valueB", cache.get("b"))
    }
}
