package com.apricot.shared.data.fixture

internal object MempoolFixtures {

    const val ADDRESS = "bc1q6gd4pye60zqrc09snv4kap89scjmrv35xsepvv"
    const val TXID_CONFIRMED = "f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16"
    const val TXID_PENDING = "abc123def456abc123def456abc123def456abc123def456abc123def456abc123"
    const val ADDRESS_FROM = "12cbQLTFMXRnSzktFkuoG3eHoMeFtpTu3S"
    const val ADDRESS_TO = "1A1zP1eP5QGefi2DMPTfTL5SLmv7Divfna"

    val addressJson = """
        {
          "address": "$ADDRESS",
          "chain_stats": {
            "funded_txo_count": 3,
            "funded_txo_sum": 150000000,
            "spent_txo_count": 1,
            "spent_txo_sum": 50000000,
            "tx_count": 3
          },
          "mempool_stats": {
            "funded_txo_count": 0,
            "funded_txo_sum": 0,
            "spent_txo_count": 0,
            "spent_txo_sum": 0,
            "tx_count": 0
          }
        }
    """.trimIndent()

    val confirmedTransactionJson = """
        {
          "txid": "$TXID_CONFIRMED",
          "version": 1,
          "locktime": 0,
          "vin": [
            {
              "txid": "0437cd7f8525ceed2324359c2d0ba26006d92d856a9c20fa0241106ee5a597c9",
              "vout": 0,
              "prevout": {
                "scriptpubkey": "4104ae1a62fe09c5f51b13905f07f06b99a2f7159b2225f374cd378d71302fa28414e7aab37397f554a7df5f142c21c1b7303b8a0626f1baded5c72a704f7e6cd84cac",
                "scriptpubkey_asm": "OP_PUSHBYTES_65 04ae1a62fe",
                "scriptpubkey_type": "p2pk",
                "scriptpubkey_address": "$ADDRESS_FROM",
                "value": 5000000000
              },
              "scriptsig": "483045022100",
              "scriptsig_asm": "OP_PUSHBYTES_72",
              "is_coinbase": false,
              "sequence": 4294967295
            }
          ],
          "vout": [
            {
              "scriptpubkey": "4104",
              "scriptpubkey_asm": "OP_PUSHBYTES_65",
              "scriptpubkey_type": "p2pk",
              "scriptpubkey_address": "$ADDRESS_TO",
              "value": 1000000000
            },
            {
              "scriptpubkey": "4104",
              "scriptpubkey_asm": "OP_PUSHBYTES_65",
              "scriptpubkey_type": "p2pk",
              "scriptpubkey_address": "$ADDRESS_FROM",
              "value": 3999990000
            }
          ],
          "size": 275,
          "weight": 1100,
          "fee": 10000,
          "status": {
            "confirmed": true,
            "block_height": 170,
            "block_hash": "00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee",
            "block_time": 1231731025
          }
        }
    """.trimIndent()

    val pendingTransactionJson = """
        {
          "txid": "$TXID_PENDING",
          "version": 1,
          "locktime": 0,
          "vin": [
            {
              "txid": "prevtxid000000000000000000000000000000000000000000000000000000001",
              "vout": 0,
              "prevout": {
                "scriptpubkey": "0014",
                "scriptpubkey_type": "p2wpkh",
                "scriptpubkey_address": "$ADDRESS",
                "value": 200000
              },
              "scriptsig": "",
              "scriptsig_asm": "",
              "is_coinbase": false,
              "sequence": 4294967295
            }
          ],
          "vout": [
            {
              "scriptpubkey": "0014",
              "scriptpubkey_type": "p2wpkh",
              "scriptpubkey_address": "$ADDRESS_TO",
              "value": 190000
            }
          ],
          "size": 140,
          "weight": 560,
          "fee": 10000,
          "status": {
            "confirmed": false
          }
        }
    """.trimIndent()

    val coinbaseTransactionJson = """
        {
          "txid": "coinbasetxid0000000000000000000000000000000000000000000000000001",
          "version": 1,
          "locktime": 0,
          "vin": [
            {
              "is_coinbase": true,
              "sequence": 4294967295
            }
          ],
          "vout": [
            {
              "scriptpubkey": "4104",
              "scriptpubkey_type": "p2pk",
              "scriptpubkey_address": "$ADDRESS_FROM",
              "value": 5000000000
            }
          ],
          "size": 134,
          "weight": 536,
          "fee": 0,
          "status": {
            "confirmed": true,
            "block_height": 1,
            "block_hash": "00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048",
            "block_time": 1231469665
          }
        }
    """.trimIndent()

    val addressTransactionsJson = """
        [
          $confirmedTransactionJson,
          $pendingTransactionJson
        ]
    """.trimIndent()
}
