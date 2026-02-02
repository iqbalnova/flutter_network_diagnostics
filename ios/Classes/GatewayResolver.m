// GatewayResolver.m
#import "GatewayResolver.h"
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <netinet/in.h>

// --- DEFINISI MANUAL (Menggantikan net/route.h) ---
#define CTL_NET         4
#define PF_ROUTE        17
#define NET_RT_FLAGS    2
#define RTF_UP          0x1
#define RTF_GATEWAY     0x2
#define RTM_VERSION     5
#define RTA_DST         0x1
#define RTA_GATEWAY     0x2
#define RTAX_DST        0
#define RTAX_GATEWAY    1
#define RTAX_MAX        8

struct rt_metrics {
    uint32_t rmx_locks;
    uint32_t rmx_mtu;
    uint32_t rmx_hopcount;
    int32_t  rmx_expire;
    uint32_t rmx_recvpipe;
    uint32_t rmx_sendpipe;
    uint32_t rmx_ssthresh;
    uint32_t rmx_rtt;
    uint32_t rmx_rttvar;
    uint32_t rmx_pksent;
    uint32_t rmx_filler[4];
};

struct rt_msghdr {
    unsigned short rtm_msglen;
    unsigned char  rtm_version;
    unsigned char  rtm_type;
    unsigned short rtm_index;
    int            rtm_flags;
    int            rtm_addrs;
    pid_t          rtm_pid;
    int            rtm_seq;
    int            rtm_errno;
    int            rtm_use;
    uint32_t       rtm_inits;
    struct rt_metrics rtm_rmx;
};

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

@implementation GatewayResolver

// Get default IPv4 gateway
+ (nullable NSString *)getDefaultGatewayIPv4 {
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char *buf, *p;
    struct rt_msghdr *rt;
    struct sockaddr *sa;
    struct sockaddr *sa_tab[RTAX_MAX];
    int i;
    NSString *gateway = nil;
    
    if (sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return nil;
    }
    
    if (l > 0) {
        buf = malloc(l);
        if (buf == NULL) {
            return nil;
        }
        
        if (sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            free(buf);
            return nil;
        }
        
        for (p = buf; p < buf + l; p += rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            
            for (i = 0; i < RTAX_MAX; i++) {
                if (rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if (((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
                && sa_tab[RTAX_DST]->sa_family == AF_INET
                && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                // Check if this is the default route (0.0.0.0)
                if (((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    char buffer[INET_ADDRSTRLEN];
                    if (inet_ntop(AF_INET, 
                                &((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr,
                                buffer, 
                                INET_ADDRSTRLEN)) {
                        gateway = [NSString stringWithUTF8String:buffer];
                        break;
                    }
                }
            }
        }
        free(buf);
    }
    
    return gateway;
}

@end