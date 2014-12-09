//
//  UPnPDeviceReachability.h
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-07-04.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"

@class SLUPnPDevice;
@class SLUPnPDeviceReachability;

@protocol SLUPnPDeviceReachabilityObserver <NSObject>

@optional

- (void)deviceDidBecomeReachable:(SLUPnPDevice *)aDevice;
- (void)deviceDidBecomeUnreachable:(SLUPnPDevice *)aDevice;

@end

@interface SLUPnPDeviceReachability : NSObject {
    NSMutableSet *observers;
    SLUPnPDevice *device;
    AFNetworkReachabilityManager *reachability;
}

- (id)initWithDevice:(SLUPnPDevice *)aDevice;

- (void)addObserver:(id <SLUPnPDeviceReachabilityObserver>)anObserver;
- (void)removeObserver:(id <SLUPnPDeviceReachabilityObserver>)anObserver;

@end
