package com.meisydevlab.flutter_network_diagnostics

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.net.wifi.WifiConfiguration
import android.net.wifi.ScanResult
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.NetworkInterface

class FlutterNetworkDiagnosticsPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var wifiSignalEventChannel: EventChannel
    private lateinit var mobileSignalEventChannel: EventChannel
    private lateinit var context: Context
    private lateinit var signalMonitor: SignalMonitor

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        signalMonitor = SignalMonitor(context)

        // Method channel for one-time calls
        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "flutter_network_diagnostics"
        )
        methodChannel.setMethodCallHandler(this)

        // Event channels for streaming
        wifiSignalEventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "flutter_network_diagnostics/wifi_signal_stream"
        )
        wifiSignalEventChannel.setStreamHandler(WifiSignalStreamHandler(signalMonitor))

        mobileSignalEventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "flutter_network_diagnostics/mobile_signal_stream"
        )
        mobileSignalEventChannel.setStreamHandler(MobileSignalStreamHandler(signalMonitor))
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            // Connection Methods
            "getDefaultGatewayIP" -> result.success(getDefaultGatewayIP())
            "getDnsServerPrimary" -> result.success(getDnsServerPrimary())
            "getDnsServerSecondary" -> result.success(getDnsServerSecondary())
            "getDefaultGatewayIPv6" -> result.success(getDefaultGatewayIPv6())
            "getDnsServerIPv6" -> result.success(getDnsServerIPv6())
            "getHttpProxy" -> result.success(getHttpProxy())

            // WiFi Information Methods
            "isNetworkConnected" -> result.success(isNetworkConnected())
            "getWifiSSID" -> result.success(getWifiSSID())
            "getWifiBSSID" -> result.success(getWifiBSSID())
            "getWifiVendor" -> result.success(getWifiVendor())
            "getWifiSecurityType" -> result.success(getWifiSecurityType())
            "getWifiIPv4Address" -> result.success(getWifiIPv4Address())
            "getSubnetMask" -> result.success(getSubnetMask())
            "getWifiIPv6Addresses" -> result.success(getWifiIPv6Addresses())
            "getBroadcastAddress" -> result.success(getBroadcastAddress())

            // Signal Meter Methods
            "getWifiSignalInfo" -> {
                val info = signalMonitor.getWifiSignalInfo()
                result.success(info)
            }
            "getMobileSignalInfo" -> {
                val info = signalMonitor.getMobileSignalInfo()
                result.success(info)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        wifiSignalEventChannel.setStreamHandler(null)
        mobileSignalEventChannel.setStreamHandler(null)
    }

    // ============================================================================
    // MARK: - CONNECTION METHODS
    // ============================================================================

    private fun getDefaultGatewayIP(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val dhcpInfo = wifiManager.dhcpInfo

            if (dhcpInfo.gateway != 0) {
                return intToIp(dhcpInfo.gateway)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getDnsServerPrimary(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val dhcpInfo = wifiManager.dhcpInfo

            if (dhcpInfo.dns1 != 0) {
                return intToIp(dhcpInfo.dns1)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getDnsServerSecondary(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val dhcpInfo = wifiManager.dhcpInfo

            if (dhcpInfo.dns2 != 0) {
                return intToIp(dhcpInfo.dns2)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getDefaultGatewayIPv6(): String? {
        return try {
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val network = connectivityManager.activeNetwork ?: return null
            val linkProperties = connectivityManager.getLinkProperties(network) ?: return null

            for (route in linkProperties.routes) {
                val gateway = route.gateway
                if (gateway is Inet6Address && !gateway.isAnyLocalAddress) {
                    val fullAddress = gateway.hostAddress ?: continue
                    val cleanAddress = fullAddress.split("%")[0]
                    
                    if (cleanAddress.isNotEmpty() && cleanAddress != ":" && cleanAddress != "::") {
                        return cleanAddress
                    }
                }
            }
            null
        } catch (e: Exception) {
            null
        }
    }

    private fun getDnsServerIPv6(): String? {
        try {
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val network = connectivityManager.activeNetwork ?: return null
            val linkProperties = connectivityManager.getLinkProperties(network) ?: return null

            for (dns in linkProperties.dnsServers) {
                if (dns is Inet6Address) {
                    return dns.hostAddress
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getHttpProxy(): String? {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                val network = connectivityManager.activeNetwork ?: return null
                val linkProperties = connectivityManager.getLinkProperties(network) ?: return null
                val httpProxy = linkProperties.httpProxy

                if (httpProxy != null) {
                    return "${httpProxy.host}:${httpProxy.port}"
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    // ============================================================================
    // MARK: - WI-FI INFORMATION METHODS
    // ============================================================================

    private fun isNetworkConnected(): Boolean {
        try {
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = connectivityManager.activeNetwork ?: return false
                val capabilities = connectivityManager.getNetworkCapabilities(network) ?: return false

                return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                        capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
            } else {
                @Suppress("DEPRECATION")
                val networkInfo = connectivityManager.activeNetworkInfo
                @Suppress("DEPRECATION")
                return networkInfo?.isConnected == true
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }

    private fun getWifiSSID(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val wifiInfo = wifiManager.connectionInfo

            if (wifiInfo != null) {
                var ssid = wifiInfo.ssid
                if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
                    ssid = ssid.substring(1, ssid.length - 1)
                }
                if (ssid != "<unknown ssid>") {
                    return ssid
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getWifiBSSID(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val wifiInfo = wifiManager.connectionInfo
            return wifiInfo?.bssid
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getWifiVendor(): String? {
        val bssid = getWifiBSSID() ?: return null
        if (bssid == "02:00:00:00:00:00") return null
        
        val oui = bssid.substring(0, 8).replace(":", "").uppercase()
        val vendor = lookupOUIVendor(oui)
        
        return if (vendor == "Unknown Vendor") null else vendor
    }

    private fun lookupOUIVendor(oui: String): String {
        val vendorMap = mapOf(
            "001122" to "Cisco Systems",
            "00259C" to "Apple",
            "0050F2" to "Microsoft",
            // ... rest of vendor map
        )
        return vendorMap[oui] ?: "Unknown Vendor"
    }

    private fun getWifiSecurityType(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val info = wifiManager.connectionInfo ?: return null
            
            val networkId = info.networkId
            val config = wifiManager.configuredNetworks?.find { it.networkId == networkId }
            
            if (config != null) {
                val allowedAuth = config.allowedKeyManagement
                return when {
                    allowedAuth.get(WifiConfiguration.KeyMgmt.WPA_PSK) -> "WPA2-PSK"
                    allowedAuth.get(WifiConfiguration.KeyMgmt.WPA_EAP) -> "WPA-EAP"
                    allowedAuth.get(WifiConfiguration.KeyMgmt.NONE) -> "Open"
                    else -> "WPA2"
                }
            }
        } catch (e: Exception) { 
            e.printStackTrace() 
        }
        return null
    }

    private fun getWifiIPv4Address(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val wifiInfo = wifiManager.connectionInfo

            if (wifiInfo.ipAddress != 0) {
                return intToIp(wifiInfo.ipAddress)
            }

            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val networkInterface = interfaces.nextElement()
                if (networkInterface.name.equals("wlan0", ignoreCase = true)) {
                    val addresses = networkInterface.inetAddresses
                    while (addresses.hasMoreElements()) {
                        val address = addresses.nextElement()
                        if (address is Inet4Address && !address.isLoopbackAddress) {
                            return address.hostAddress
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getSubnetMask(): String? {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val networkInterface = interfaces.nextElement()
                if (networkInterface.name.equals("wlan0", ignoreCase = true)) {
                    for (interfaceAddress in networkInterface.interfaceAddresses) {
                        val address = interfaceAddress.address
                        if (address is Inet4Address && !address.isLoopbackAddress) {
                            val prefixLength = interfaceAddress.networkPrefixLength
                            return getSubnetMaskFromPrefix(prefixLength.toInt())
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getWifiIPv6Addresses(): List<String>? {
        try {
            val ipv6List = mutableListOf<String>()
            val interfaces = NetworkInterface.getNetworkInterfaces()

            while (interfaces.hasMoreElements()) {
                val networkInterface = interfaces.nextElement()
                if (networkInterface.name.equals("wlan0", ignoreCase = true)) {
                    for (interfaceAddress in networkInterface.interfaceAddresses) {
                        val address = interfaceAddress.address
                        if (address is Inet6Address && !address.isLoopbackAddress) {
                            val prefixLength = interfaceAddress.networkPrefixLength
                            ipv6List.add("${address.hostAddress}/$prefixLength")
                        }
                    }
                }
            }

            return if (ipv6List.isNotEmpty()) ipv6List else null
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getBroadcastAddress(): String? {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val networkInterface = interfaces.nextElement()
                if (networkInterface.name.equals("wlan0", ignoreCase = true)) {
                    for (interfaceAddress in networkInterface.interfaceAddresses) {
                        val broadcast = interfaceAddress.broadcast
                        if (broadcast != null) {
                            return broadcast.hostAddress
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    // ============================================================================
    // MARK: - HELPER METHODS
    // ============================================================================

    private fun intToIp(ip: Int): String {
        return String.format(
            "%d.%d.%d.%d",
            ip and 0xff,
            ip shr 8 and 0xff,
            ip shr 16 and 0xff,
            ip shr 24 and 0xff
        )
    }

    private fun getSubnetMaskFromPrefix(prefixLength: Int): String {
        val mask = -0x1 shl (32 - prefixLength)
        return String.format(
            "%d.%d.%d.%d",
            mask shr 24 and 0xff,
            mask shr 16 and 0xff,
            mask shr 8 and 0xff,
            mask and 0xff
        )
    }
}

// ============================================================================
// MARK: - SIGNAL METER STREAM HANDLERS
// ============================================================================
class WifiSignalStreamHandler(
    private val signalMonitor: SignalMonitor
) : EventChannel.StreamHandler {
    private var handler: Handler? = null
    private var runnable: Runnable? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null) return

        val args = arguments as? Map<*, *>
        val intervalMs = (args?.get("intervalMs") as? Int)?.toLong() ?: 1000L

        handler = Handler(Looper.getMainLooper())
        runnable = object : Runnable {
            override fun run() {
                try {
                    val info = signalMonitor.getWifiSignalInfo()
                    // FIXED: Always send valid data, even if null
                    if (info != null) {
                        events.success(info)
                    } else {
                        // Send a proper "not connected" response
                        events.success(mapOf(
                            "timestamp" to System.currentTimeMillis(),
                            "isConnected" to false
                        ))
                    }
                } catch (e: SecurityException) {
                    // Permission was revoked
                    events.error("PERMISSION_DENIED", "Location permission required", null)
                } catch (e: Exception) {
                    // Don't crash, just send error
                    events.error("WIFI_SIGNAL_ERROR", e.message ?: "Unknown error", null)
                }
                // Continue polling even after errors
                handler?.postDelayed(this, intervalMs)
            }
        }
        handler?.post(runnable!!)
    }

    override fun onCancel(arguments: Any?) {
        runnable?.let { handler?.removeCallbacks(it) }
        handler = null
        runnable = null
    }
}

class MobileSignalStreamHandler(
    private val signalMonitor: SignalMonitor
) : EventChannel.StreamHandler {
    private var handler: Handler? = null
    private var runnable: Runnable? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null) return

        val args = arguments as? Map<*, *>
        val intervalMs = (args?.get("intervalMs") as? Int)?.toLong() ?: 1000L

        handler = Handler(Looper.getMainLooper())
        runnable = object : Runnable {
            override fun run() {
                try {
                    val info = signalMonitor.getMobileSignalInfo()
                    // FIXED: SignalMonitor now always returns a Map, never null
                    // This prevents "Invalid mobile signal data format" errors
                    events.success(info)
                } catch (e: SecurityException) {
                    // Permission was revoked - send safe response
                    events.success(mapOf(
                        "timestamp" to System.currentTimeMillis(),
                        "isConnected" to false
                    ))
                } catch (e: Exception) {
                    // Send a safe response instead of error to prevent stream disruption
                    events.success(mapOf(
                        "timestamp" to System.currentTimeMillis(),
                        "isConnected" to false
                    ))
                }
                // Continue polling even after errors
                handler?.postDelayed(this, intervalMs)
            }
        }
        handler?.post(runnable!!)
    }

    override fun onCancel(arguments: Any?) {
        runnable?.let { handler?.removeCallbacks(it) }
        handler = null
        runnable = null
    }
}