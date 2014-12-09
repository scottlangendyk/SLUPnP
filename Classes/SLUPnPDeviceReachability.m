//
//  UPnPDeviceReachability.m
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-07-04.
//
//

#import "SLUPnPDeviceReachability.h"
#import "SLUPnPDevice.h"
#include <arpa/inet.h>

@implementation SLUPnPDeviceReachability

- (id)initWithDevice:(SLUPnPDevice *)aDevice
{
    self = [super init];
    
    if (self) {
        device = aDevice;
    }
    
    return self;
}

- (void)addObserver:(id <SLUPnPDeviceReachabilityObserver>)anObserver
{
    if (!observers) {
        observers = [[NSMutableSet alloc] init];
    }
    
    [observers addObject:anObserver];
    
    [self monitor];
}

- (void)removeObserver:(id <SLUPnPDeviceReachabilityObserver>)anObserver
{
    [observers removeObject:anObserver];
    
    if (observers && [observers count] == 0) {
        [reachability stopMonitoring];
        
        reachability = nil;
    }
}

- (void)monitor
{
    if (reachability) {
        return;
    }
    
    struct sockaddr_in address;
    
    address.sin_family = AF_INET;
    address.sin_len = sizeof(address);
    address.sin_port = htons([[[device descriptionURL] port] intValue]);
    
    inet_pton(AF_INET, [[[device descriptionURL] host] UTF8String], &address.sin_addr);
    
    reachability = [AFNetworkReachabilityManager managerForAddress:&address];
    
    __weak typeof(self) weakSelf = self;
    
    [reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [weakSelf notifyObserversDeviceReachable];
        } else {
            [weakSelf notifyObserversDeviceUnreachable];
        }
    }];
    
    [reachability startMonitoring];
}

- (void)notifyObserversDeviceReachable
{
    for (id <SLUPnPDeviceReachabilityObserver> observer in observers) {
        if ([observer respondsToSelector:@selector(deviceDidBecomeReachable:)]) {
            [observer deviceDidBecomeReachable:device];
        }
    }
}

- (void)notifyObserversDeviceUnreachable
{
    for (id <SLUPnPDeviceReachabilityObserver> observer in observers) {
        if ([observer respondsToSelector:@selector(deviceDidBecomeUnreachable:)]) {
            [observer deviceDidBecomeUnreachable:device];
        }
    }
}

@end
