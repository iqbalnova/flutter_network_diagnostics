import Flutter
import UIKit
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import Foundation

public class FlutterNetworkDiagnosticsPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "flutter_network_diagnostics",
            binaryMessenger: registrar.messenger()
        )
        
        // Event channels for signal monitoring (unsupported on iOS)
        let wifiEventChannel = FlutterEventChannel(
            name: "flutter_network_diagnostics/wifi_signal_stream",
            binaryMessenger: registrar.messenger()
        )
        
        let mobileEventChannel = FlutterEventChannel(
            name: "flutter_network_diagnostics/mobile_signal_stream",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = FlutterNetworkDiagnosticsPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        // Set stream handlers for signal monitoring
        wifiEventChannel.setStreamHandler(instance)
        mobileEventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDefaultGatewayIP":
            result(getDefaultGatewayIP())
        case "getDnsServerPrimary":
            result(getDnsServerPrimary())
        case "getDnsServerSecondary":
            result(getDnsServerSecondary())
        case "getDefaultGatewayIPv6":
            result(getDefaultGatewayIPv6())
        case "getDnsServerIPv6":
            result(getDnsServerIPv6())
        case "getHttpProxy":
            result(getHttpProxy())
        case "isNetworkConnected":
            result(isNetworkConnected())
        case "getWifiSSID":
            result(getWifiSSID())
        case "getWifiBSSID":
            result(getWifiBSSID())
        case "getWifiVendor":
            result(getWifiVendor())
        case "getWifiSecurityType":
            result(getWifiSecurityType())
        case "getWifiIPv4Address":
            result(getWifiIPv4Address())
        case "getSubnetMask":
            result(getSubnetMask())
        case "getWifiIPv6Addresses":
            result(getWifiIPv6Addresses())
        case "getBroadcastAddress":
            result(getBroadcastAddress())
            
        // Signal monitoring methods (unsupported on iOS)
        case "getWifiSignalInfo":
            result(FlutterError(
                code: "UNSUPPORTED",
                message: "Wi-Fi signal monitoring is not supported on iOS",
                details: "iOS does not provide APIs for accessing RSSI and detailed Wi-Fi signal information"
            ))
        case "getMobileSignalInfo":
            result(FlutterError(
                code: "UNSUPPORTED",
                message: "Mobile signal monitoring is not supported on iOS",
                details: "iOS does not provide public APIs for accessing cellular signal strength"
            ))
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - FlutterStreamHandler (for signal monitoring)
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        // Immediately send error for unsupported signal monitoring on iOS
        events(FlutterError(
            code: "UNSUPPORTED",
            message: "Real-time signal monitoring is not supported on iOS",
            details: "iOS does not provide APIs for continuous Wi-Fi or cellular signal monitoring"
        ))
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // Nothing to cancel on iOS
        return nil
    }
    
    // MARK: - Connection Methods
    
    private func getDefaultGatewayIP() -> String? {
        return GatewayResolver.getDefaultGatewayIPv4()
    }
    
    private func getDnsServerPrimary() -> String? {
        let servers = getDnsServers()
        return servers.first { !$0.contains(":") }
    }
    
    private func getDnsServerSecondary() -> String? {
        let servers = getDnsServers()
        let ipv4Servers = servers.filter { !$0.contains(":") }
        return ipv4Servers.count > 1 ? ipv4Servers[1] : nil
    }
    
    private func getDnsServers() -> [String] {
        return DNSResolver.getDNSServers() as! [String]
    }
    
    private func getDefaultGatewayIPv6() -> String? {
        return nil
    }
    
    private func getDnsServerIPv6() -> String? {
        return DNSResolver.getDNSServerIPv6()
    }
    
    private func getHttpProxy() -> String? {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return nil
        }
        
        if let httpProxy = proxySettings["HTTPProxy"] as? String,
           let httpPort = proxySettings["HTTPPort"] as? Int {
            return "\(httpProxy):\(httpPort)"
        }
        
        return nil
    }
    
    // MARK: - WiFi Methods
    
    private func isNetworkConnected() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    private func getWifiSSID() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                   let ssid = info[kCNNetworkInfoKeySSID as String] as? String {
                    return ssid
                }
            }
        }
        return nil
    }
    
    private func getWifiBSSID() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                   let bssid = info[kCNNetworkInfoKeyBSSID as String] as? String {
                    return bssid
                }
            }
        }
        return nil
    }
    
    private func getWifiVendor() -> String? {
        return nil
    }
    
    private func getWifiSecurityType() -> String? {
        return nil
    }
    
    private func getWifiIPv4Address() -> String? {
        // Only return if we have an active connection
        guard isInterfaceActive() else { return nil }
        return getIPAddress(family: AF_INET)
    }
    
    private func getSubnetMask() -> String? {
        // Only return if we have an active connection
        guard isInterfaceActive() else { return nil }
        
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else { return nil }
        defer { freeifaddrs(interfaces) }
        
        var ptr = interfaces
        while ptr != nil {
            defer { ptr = ptr!.pointee.ifa_next }
            
            guard let interface = ptr?.pointee,
                  let addrPtr = interface.ifa_addr else {
                continue
            }
            
            let addrFamily = addrPtr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                // Check if interface is up and running
                if name.hasPrefix("en") && isInterfaceUp(interface.ifa_flags) {
                    if let netmask = interface.ifa_netmask {
                        var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                        let netmaskAddr = netmask.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr }
                        var addr = netmaskAddr
                        inet_ntop(AF_INET, &addr, &buffer, socklen_t(INET_ADDRSTRLEN))
                        return String(cString: buffer)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func getWifiIPv6Addresses() -> [String]? {
        // Only return if we have an active connection
        guard isInterfaceActive() else { return nil }
        
        var ipv6Addresses: [String] = []
        
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else { return nil }
        defer { freeifaddrs(interfaces) }
        
        var ptr = interfaces
        while ptr != nil {
            defer { ptr = ptr!.pointee.ifa_next }
            
            guard let interface = ptr?.pointee,
                  let addrPtr = interface.ifa_addr else {
                continue
            }
            
            let addrFamily = addrPtr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                // Check if interface is up and running
                if name.hasPrefix("en") && isInterfaceUp(interface.ifa_flags) {
                    var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
                    let addr = addrPtr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { $0.pointee.sin6_addr }
                    var ipv6Addr = addr
                    inet_ntop(AF_INET6, &ipv6Addr, &buffer, socklen_t(INET6_ADDRSTRLEN))
                    let ipv6String = String(cString: buffer)
                    
                    // Exclude link-local addresses (fe80::)
                    if !ipv6String.isEmpty && !ipv6String.hasPrefix("fe80") {
                        ipv6Addresses.append(ipv6String)
                    }
                }
            }
        }
        
        return ipv6Addresses.isEmpty ? nil : ipv6Addresses
    }
    
    private func getBroadcastAddress() -> String? {
        // Only return if we have an active connection
        guard isInterfaceActive() else { return nil }
        
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else { return nil }
        defer { freeifaddrs(interfaces) }
        
        var ptr = interfaces
        while ptr != nil {
            defer { ptr = ptr!.pointee.ifa_next }
            
            guard let interface = ptr?.pointee,
                  let addrPtr = interface.ifa_addr else {
                continue
            }
            
            let addrFamily = addrPtr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                // Check if interface is up, running, and supports broadcast
                if name.hasPrefix("en") && 
                   isInterfaceUp(interface.ifa_flags) &&
                   (interface.ifa_flags & UInt32(IFF_BROADCAST)) != 0 {
                    if let dstaddr = interface.ifa_dstaddr {
                        var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                        let broadcastAddr = dstaddr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr }
                        var addr = broadcastAddr
                        inet_ntop(AF_INET, &addr, &buffer, socklen_t(INET_ADDRSTRLEN))
                        return String(cString: buffer)
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    private func getIPAddress(family: Int32) -> String? {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else { return nil }
        defer { freeifaddrs(interfaces) }
        
        var ptr = interfaces
        while ptr != nil {
            defer { ptr = ptr!.pointee.ifa_next }
            
            guard let interface = ptr?.pointee,
                  let addrPtr = interface.ifa_addr else {
                continue
            }
            
            let addrFamily = addrPtr.pointee.sa_family
            
            if addrFamily == UInt8(family) {
                let name = String(cString: interface.ifa_name)
                // Check if interface is up and running
                if name.hasPrefix("en") && isInterfaceUp(interface.ifa_flags) {
                    if family == AF_INET {
                        var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                        let addr = addrPtr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr }
                        var ipAddr = addr
                        inet_ntop(AF_INET, &ipAddr, &buffer, socklen_t(INET_ADDRSTRLEN))
                        let ipString = String(cString: buffer)
                        
                        // Ignore 169.254.x.x (APIPA/link-local addresses)
                        if !ipString.hasPrefix("169.254") {
                            return ipString
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    // Check if interface is up and running
    private func isInterfaceUp(_ flags: UInt32) -> Bool {
        return (flags & UInt32(IFF_UP)) != 0 && (flags & UInt32(IFF_RUNNING)) != 0
    }
    
    // Check if we have an active network interface
    private func isInterfaceActive() -> Bool {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else { return false }
        defer { freeifaddrs(interfaces) }
        
        var ptr = interfaces
        while ptr != nil {
            defer { ptr = ptr!.pointee.ifa_next }
            
            guard let interface = ptr?.pointee,
                  let addrPtr = interface.ifa_addr else {
                continue
            }
            
            let name = String(cString: interface.ifa_name)
            let addrFamily = addrPtr.pointee.sa_family
            
            // Check for active en* interface with IPv4 address
            if name.hasPrefix("en") && 
               addrFamily == UInt8(AF_INET) &&
               isInterfaceUp(interface.ifa_flags) {
                
                // Get the IP address
                var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                let addr = addrPtr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr }
                var ipAddr = addr
                inet_ntop(AF_INET, &ipAddr, &buffer, socklen_t(INET_ADDRSTRLEN))
                let ipString = String(cString: buffer)
                
                // Ignore link-local (169.254.x.x) and loopback (127.x.x.x)
                if !ipString.hasPrefix("169.254") && !ipString.hasPrefix("127.") {
                    return true
                }
            }
        }
        
        return false
    }
}