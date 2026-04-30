package com.apricot.shared.cache

internal class TtlCache<K, V>(private val clock: Clock) {

    private data class Entry<V>(val value: V, val expiresAtMillis: Long)

    private val store = mutableMapOf<K, Entry<V>>()

    fun get(key: K): V? {
        val entry = store[key] ?: return null
        return if (clock.nowMillis() < entry.expiresAtMillis) {
            entry.value
        } else {
            store.remove(key)
            null
        }
    }

    fun put(key: K, value: V, ttlMillis: Long) {
        store[key] = Entry(value, clock.nowMillis() + ttlMillis)
    }
}
