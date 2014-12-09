//
//  SLUPnPDeviceFinder.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-11-26.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLUPnPDevice.h"
#import "SLSSDPServer.h"
#import "SLUPnPDevices.h"
#import "SLUPnPDeviceLoader.h"

@class SLUPnPDeviceFinder;

@protocol SLUPnPDeviceFinderDelegate <NSObject>

- (void)deviceFinder:(SLUPnPDeviceFinder *)deviceFinder didFindDevice:(SLUPnPDevice *)device;

@end

@interface SLUPnPDeviceFinder : NSObject <SLSSDPServerObserver> {
    NSMutableSet *_devices;
}

@property (readonly) NSString *target;
@property (nonatomic) id <SLUPnPDeviceFinderDelegate> delegate;
@property (readonly, getter=isSearching) BOOL searching;
@property (nonatomic) SLUPnPDeviceLoader *loader;
@property (nonatomic) NSTimeInterval searchInterval;

- (id)initWithTarget:(NSString *)target;

- (void)startSearching;
- (void)stopSearching;

@end
