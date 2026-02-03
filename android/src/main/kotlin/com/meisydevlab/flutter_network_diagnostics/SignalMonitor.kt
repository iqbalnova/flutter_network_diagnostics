// android/src/main/kotlin/com/meisydevlab/flutter_network_diagnostics/SignalMonitor.kt

package com.meisydevlab.flutter_network_diagnostics

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.telephony.*
import androidx.core.app.ActivityCompat

class SignalMonitor(private val context: Context) {

    private val wifiManager: WifiManager? =
        context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager

    private val telephonyManager: TelephonyManager? =
        context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager

    private val connectivityManager: ConnectivityManager? =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager

    /**
     * Get current Wi-Fi signal information
     */
    fun getWifiSignalInfo(): Map<String, Any?>? {
        if (!hasLocationPermission()) return null

        val wifiInfo = getWifiInfo() ?: return null

        return buildMap {
            put("timestamp", System.currentTimeMillis())
            put("isConnected", true)
            put("rssi", wifiInfo.rssi)
            
            // Properly handle SSID with quote removal
            val ssid = wifiInfo.ssid?.let { rawSsid ->
                var cleaned = rawSsid
                if (cleaned.startsWith("\"") && cleaned.endsWith("\"")) {
                    cleaned = cleaned.substring(1, cleaned.length - 1)
                }
                if (cleaned != "<unknown ssid>") cleaned else null
            }
            put("ssid", ssid)
            
            put("bssid", wifiInfo.bssid)
            put("frequency", wifiInfo.frequency)
            put("linkSpeed", wifiInfo.linkSpeed)

            // API 29+: Max link speed
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put("maxLinkSpeed", wifiInfo.maxSupportedTxLinkSpeedMbps)
            }

            // API 31+: TX/RX speeds
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                put("txLinkSpeed", wifiInfo.txLinkSpeedMbps)
                put("rxLinkSpeed", wifiInfo.rxLinkSpeedMbps)
            }

            // Channel width
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                put("channelWidth", getChannelWidth())
            }

            // Wi-Fi standard (API 30+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                put("wifiStandard", getWifiStandard(wifiInfo))
            }
        }
    }

    /**
     * Get current mobile signal information
     * FIXED: Now checks SIM state instead of internet connection
     */
    fun getMobileSignalInfo(): Map<String, Any?> {
        if (!hasPhonePermission()) {
            return buildMap {
                put("timestamp", System.currentTimeMillis())
                put("isConnected", false)
            }
        }

        val telephonyManager = this.telephonyManager ?: return buildMap {
            put("timestamp", System.currentTimeMillis())
            put("isConnected", false)
        }

        return try {
            buildMap {
                put("timestamp", System.currentTimeMillis())
                
                // FIXED: Check if SIM is ready and service is available
                // NOT checking for internet connection!
                val hasSignal = hasNetworkService()
                put("isConnected", hasSignal)

                if (!hasSignal) {
                    // Still return basic info even without signal
                    put("operatorName", telephonyManager.networkOperatorName ?: "No Service")
                    return@buildMap
                }

                // Operator info - works without internet
                put("operatorName", telephonyManager.networkOperatorName ?: "Unknown")
                put("isRoaming", telephonyManager.isNetworkRoaming)

                // Network type and generation - works without internet
                val networkType = getNetworkType()
                put("networkGeneration", getNetworkGeneration(networkType))
                put("networkTechnology", getNetworkTechnology(networkType))

                // Signal strength - works without internet
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    val signalStrength = telephonyManager.signalStrength
                    if (signalStrength != null) {
                        putAll(extractSignalMetrics(signalStrength))
                    }
                } else {
                    try {
                        val cellInfo = telephonyManager.allCellInfo?.firstOrNull()
                        if (cellInfo != null) {
                            putAll(extractLegacySignalMetrics(cellInfo))
                        }
                    } catch (e: SecurityException) {
                        // Permission might have been revoked
                    }
                }
            }
        } catch (e: Exception) {
            buildMap {
                put("timestamp", System.currentTimeMillis())
                put("isConnected", false)
            }
        }
    }

    // ============================================================================
    // Wi-Fi Helper Methods
    // ============================================================================

    private fun getWifiInfo(): WifiInfo? {
        return try {
            // Always use wifiManager.connectionInfo
            wifiManager?.connectionInfo
        } catch (e: Exception) {
            null
        }
    }

    @androidx.annotation.RequiresApi(Build.VERSION_CODES.R)
    private fun getChannelWidth(): Int {
        return 0
    }

    @androidx.annotation.RequiresApi(Build.VERSION_CODES.R)
    private fun getWifiStandard(wifiInfo: WifiInfo): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return try {
                val wifiStandard = wifiInfo.wifiStandard
                
                when (wifiStandard) {
                    4 -> "Wi-Fi 4"
                    5 -> "Wi-Fi 5"
                    6 -> "Wi-Fi 6"
                    else -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        when (wifiStandard) {
                            7 -> "Wi-Fi 6E"
                            else -> "Unknown"
                        }
                    } else {
                        "Unknown"
                    }
                }
            } catch (e: Exception) {
                "Unknown"
            }
        }
        return "Unknown"
    }

    // ============================================================================
    // Mobile Network Helper Methods
    // ============================================================================

    /**
     * FIXED: Check if device has network service (SIM registered)
     * This does NOT require internet connection!
     */
    private fun hasNetworkService(): Boolean {
        return try {
            val telephonyManager = this.telephonyManager ?: return false
            
            // Check SIM state
            val simState = telephonyManager.simState
            if (simState != TelephonyManager.SIM_STATE_READY) {
                return false
            }

            // Check service state (are we registered to a network?)
            val networkType = getNetworkType()
            if (networkType == TelephonyManager.NETWORK_TYPE_UNKNOWN) {
                return false
            }

            // If we have a network type and SIM is ready, we have service
            // Even without internet data!
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun getNetworkType(): Int {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                telephonyManager?.dataNetworkType ?: TelephonyManager.NETWORK_TYPE_UNKNOWN
            } else {
                @Suppress("DEPRECATION")
                telephonyManager?.networkType ?: TelephonyManager.NETWORK_TYPE_UNKNOWN
            }
        } catch (e: Exception) {
            TelephonyManager.NETWORK_TYPE_UNKNOWN
        }
    }

    private fun getNetworkGeneration(networkType: Int): String {
        return when (networkType) {
            TelephonyManager.NETWORK_TYPE_GPRS,
            TelephonyManager.NETWORK_TYPE_EDGE,
            TelephonyManager.NETWORK_TYPE_CDMA,
            TelephonyManager.NETWORK_TYPE_1xRTT,
            TelephonyManager.NETWORK_TYPE_IDEN -> "2G"

            TelephonyManager.NETWORK_TYPE_UMTS,
            TelephonyManager.NETWORK_TYPE_EVDO_0,
            TelephonyManager.NETWORK_TYPE_EVDO_A,
            TelephonyManager.NETWORK_TYPE_HSDPA,
            TelephonyManager.NETWORK_TYPE_HSUPA,
            TelephonyManager.NETWORK_TYPE_HSPA,
            TelephonyManager.NETWORK_TYPE_EVDO_B,
            TelephonyManager.NETWORK_TYPE_EHRPD,
            TelephonyManager.NETWORK_TYPE_HSPAP -> "3G"

            TelephonyManager.NETWORK_TYPE_LTE -> "4G"

            TelephonyManager.NETWORK_TYPE_NR -> "5G"

            else -> "Unknown"
        }
    }

    private fun getNetworkTechnology(networkType: Int): String {
        return when (networkType) {
            TelephonyManager.NETWORK_TYPE_GPRS -> "GPRS"
            TelephonyManager.NETWORK_TYPE_EDGE -> "EDGE"
            TelephonyManager.NETWORK_TYPE_UMTS -> "UMTS"
            TelephonyManager.NETWORK_TYPE_HSDPA -> "HSDPA"
            TelephonyManager.NETWORK_TYPE_HSUPA -> "HSUPA"
            TelephonyManager.NETWORK_TYPE_HSPA -> "HSPA"
            TelephonyManager.NETWORK_TYPE_CDMA -> "CDMA"
            TelephonyManager.NETWORK_TYPE_EVDO_0 -> "EVDO"
            TelephonyManager.NETWORK_TYPE_LTE -> "LTE"
            TelephonyManager.NETWORK_TYPE_NR -> "5G NR"
            else -> "Unknown"
        }
    }

    @androidx.annotation.RequiresApi(Build.VERSION_CODES.P)
    private fun extractSignalMetrics(signalStrength: SignalStrength): Map<String, Any?> {
        return buildMap {
            try {
                val cellSignalStrengths = signalStrength.cellSignalStrengths

                if (cellSignalStrengths.isNotEmpty()) {
                    val primarySignal = cellSignalStrengths[0]

                    put("signalStrength", primarySignal.dbm)
                    put("asuLevel", primarySignal.asuLevel)
                    put("level", primarySignal.level)

                    when (primarySignal) {
                        is CellSignalStrengthLte -> {
                            put("rsrp", primarySignal.rsrp)
                            put("rsrq", primarySignal.rsrq)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                put("sinr", primarySignal.rssnr)
                            }
                        }
                        is CellSignalStrengthNr -> {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                put("rsrp", primarySignal.ssRsrp)
                                put("rsrq", primarySignal.ssRsrq)
                                put("sinr", primarySignal.ssSinr)
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // Silently fail
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun extractLegacySignalMetrics(cellInfo: CellInfo): Map<String, Any?> {
        return buildMap {
            try {
                when (cellInfo) {
                    is CellInfoGsm -> {
                        put("signalStrength", cellInfo.cellSignalStrength.dbm)
                        put("asuLevel", cellInfo.cellSignalStrength.asuLevel)
                        put("level", cellInfo.cellSignalStrength.level)
                    }
                    is CellInfoCdma -> {
                        put("signalStrength", cellInfo.cellSignalStrength.dbm)
                        put("asuLevel", cellInfo.cellSignalStrength.asuLevel)
                        put("level", cellInfo.cellSignalStrength.level)
                    }
                    is CellInfoLte -> {
                        put("signalStrength", cellInfo.cellSignalStrength.dbm)
                        put("asuLevel", cellInfo.cellSignalStrength.asuLevel)
                        put("level", cellInfo.cellSignalStrength.level)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            put("rsrp", cellInfo.cellSignalStrength.rsrp)
                            put("rsrq", cellInfo.cellSignalStrength.rsrq)
                        }
                    }
                }
            } catch (e: Exception) {
                // Silently fail
            }
        }
    }

    // ============================================================================
    // Permission Helpers
    // ============================================================================

    private fun hasLocationPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun hasPhonePermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED
    }
}