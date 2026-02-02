package com.meisydevlab.flutter_network_diagnostics

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.net.wifi.WifiConfiguration
import android.net.wifi.ScanResult
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.NetworkInterface
import java.nio.ByteBuffer
import java.nio.ByteOrder


class FlutterNetworkDiagnosticsPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_network_diagnostics")
        channel.setMethodCallHandler(this)
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

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
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
            // Pastikan gateway adalah IPv6 dan bukan alamat kosong (::)
            if (gateway is Inet6Address && !gateway.isAnyLocalAddress) {
                val fullAddress = gateway.hostAddress ?: continue
                
                // Bersihkan scope ID
                val cleanAddress = fullAddress.split("%")[0]
                
                // Validasi tambahan: Jika hasilnya hanya ":" atau "::", anggap null
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
                // Remove quotes if present
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
        // Jika BSSID adalah default/randomized, kita tidak bisa menebak vendor
        if (bssid == "02:00:00:00:00:00") return null
        
        val oui = bssid.substring(0, 8).replace(":", "").uppercase()
        val vendor = lookupOUIVendor(oui)
        
        return if (vendor == "Unknown Vendor") null else vendor
    }

    private fun lookupOUIVendor(oui: String): String {
        // Common vendor OUI mappings (first 6 characters of MAC)
        val vendorMap = mapOf(
            "001122" to "Cisco Systems",
            "00259C" to "Apple",
            "0050F2" to "Microsoft",
            "001B63" to "Apple",
            "0017F2" to "Apple",
            "001EC2" to "Apple",
            "001FF3" to "Apple",
            "0023DF" to "Apple",
            "002436" to "Apple",
            "0025BC" to "Apple",
            "002608" to "Apple",
            "0026BB" to "Apple",
            "00A040" to "Apple",
            "5CF938" to "Apple",
            "A4C361" to "Apple",
            "D8004D" to "Apple",
            "DC2B61" to "Apple",
            "E85B5B" to "Apple",
            "F0B479" to "Apple",
            "F099BF" to "Apple",
            "000C42" to "TP-Link",
            "001D0F" to "TP-Link",
            "002191" to "D-Link",
            "0050BA" to "D-Link",
            "001CF0" to "D-Link",
            "0018E7" to "Netgear",
            "002275" to "Netgear",
            "9CD21E" to "Netgear",
            "A021B7" to "Netgear",
            "C40415" to "Netgear",
            "000F66" to "Linksys",
            "0013C4" to "Arris",
            "001ADB" to "Google",
            "3C5A37" to "Google",
            "54EABE" to "Samsung",
            "581FAA" to "Huawei",
            "8C3BAD" to "Xiaomi",
            "642737" to "Asus"
        )

        return vendorMap[oui] ?: "Unknown Vendor"
    }

    private fun getWifiSecurityType(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val info = wifiManager.connectionInfo ?: return null
            
            // Pada Android 12+ (API 31), kita bisa mendapatkan info keamanan yang lebih akurat
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                val network = connectivityManager.activeNetwork
                val capabilities = connectivityManager.getNetworkCapabilities(network)
                
                // Menggunakan scanning atau link properties untuk mendeteksi tipe spesifik
                // Namun cara termudah yang kompatibel adalah via WifiConfiguration/ScanResult
            }

            // Fallback menggunakan scan results atau connection info
            // Catatan: Membutuhkan izin ACCESS_FINE_LOCATION
            val networkId = info.networkId
            val config = wifiManager.configuredNetworks?.find { it.networkId == networkId }
            
            if (config != null) {
                val allowedAuth = config.allowedKeyManagement
                return when {
                    allowedAuth.get(WifiConfiguration.KeyMgmt.WPA_PSK) -> "WPA2-PSK"
                    allowedAuth.get(WifiConfiguration.KeyMgmt.WPA_EAP) -> "WPA-EAP"
                    allowedAuth.get(WifiConfiguration.KeyMgmt.SAE) -> "WPA3-SAE"
                    allowedAuth.get(WifiConfiguration.KeyMgmt.NONE) -> "Open"
                    else -> "WPA2"
                }
            }
        } catch (e: Exception) { e.printStackTrace() }
        return null
    }

    private fun getWifiIPv4Address(): String? {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val wifiInfo = wifiManager.connectionInfo

            if (wifiInfo.ipAddress != 0) {
                return intToIp(wifiInfo.ipAddress)
            }

            // Alternative method using NetworkInterface
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