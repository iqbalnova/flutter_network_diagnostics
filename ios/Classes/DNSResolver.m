#import "DNSResolver.h"
#import <resolv.h>
#import <arpa/inet.h>
#import <netinet/in.h>

@implementation DNSResolver

// Method 1: Mengambil semua DNS (IPv4 & IPv6)
+ (NSArray<NSString *> *)getDNSServers {
    NSMutableArray<NSString *> *dnsServers = [NSMutableArray array];
    
    res_state res = malloc(sizeof(struct __res_state));
    if (res_ninit(res) == 0) {
        union res_9_sockaddr_union addrs[MAXNS];
        int count = res_getservers(res, addrs, MAXNS);
        
        for (int i = 0; i < count; i++) {
            char buffer[INET6_ADDRSTRLEN];
            
            if (addrs[i].sin.sin_family == AF_INET) {
                if (inet_ntop(AF_INET, &addrs[i].sin.sin_addr, buffer, INET_ADDRSTRLEN)) {
                    [dnsServers addObject:[NSString stringWithUTF8String:buffer]];
                }
            } else if (addrs[i].sin6.sin6_family == AF_INET6) {
                if (inet_ntop(AF_INET6, &addrs[i].sin6.sin6_addr, buffer, INET6_ADDRSTRLEN)) {
                    [dnsServers addObject:[NSString stringWithUTF8String:buffer]];
                }
            }
        }
        res_nclose(res);
    }
    free(res);
    return [dnsServers copy];
}

// Method 2: Khusus mengambil satu alamat IPv6 (jika ada)
+ (nullable NSString *)getDNSServerIPv6 {
    NSString *ipv6Address = nil;
    
    res_state res = malloc(sizeof(struct __res_state));
    if (res_ninit(res) == 0) {
        union res_9_sockaddr_union addrs[MAXNS];
        int count = res_getservers(res, addrs, MAXNS);
        
        for (int i = 0; i < count; i++) {
            if (addrs[i].sin6.sin6_family == AF_INET6) {
                char buffer[INET6_ADDRSTRLEN];
                if (inet_ntop(AF_INET6, &addrs[i].sin6.sin6_addr, buffer, INET6_ADDRSTRLEN)) {
                    ipv6Address = [NSString stringWithUTF8String:buffer];
                    break; // Ambil yang pertama ditemukan lalu keluar
                }
            }
        }
        res_nclose(res);
    }
    free(res);
    return ipv6Address;
}

@end

// // Method 3: Mengambil semua DNS (IPv4)
// #import "DNSResolver.h"
// #import <resolv.h>
// #import <arpa/inet.h>

// @implementation DNSResolver

// + (NSArray<NSString *> *)getDNSServers {
//     NSMutableArray<NSString *> *dnsServers = [NSMutableArray array];
    
//     res_state res = malloc(sizeof(struct __res_state));
//     if (res_ninit(res) == 0) {
//         for (int i = 0; i < res->nscount; i++) {
//             struct sockaddr_in addr = res->nsaddr_list[i];
            
//             if (addr.sin_family == AF_INET) {
//                 char buffer[INET_ADDRSTRLEN];
//                 if (inet_ntop(AF_INET, &addr.sin_addr, buffer, INET_ADDRSTRLEN) != NULL) {
//                     NSString *ipString = [NSString stringWithUTF8String:buffer];
//                     if (ipString.length > 0 && ![ipString isEqualToString:@"0.0.0.0"]) {
//                         [dnsServers addObject:ipString];
//                     }
//                 }
//             }
//         }
//         res_nclose(res);
//     }
//     free(res);
    
//     return [dnsServers copy];
// }

// @end