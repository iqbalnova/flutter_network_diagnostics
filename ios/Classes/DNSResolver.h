#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSResolver : NSObject

+ (NSArray<NSString *> *)getDNSServers;
+ (nullable NSString *)getDNSServerIPv6;

@end

NS_ASSUME_NONNULL_END