//
//  SLUPnPDeviceLoader.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-10-27.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLUPnPDevice.h"
#import "SLSSDPMessage.h"

@interface SLUPnPDeviceLoader : NSObject {
    NSMapTable *_devicesMap;
}

+ (SLUPnPDeviceLoader *)sharedLoader;

- (void)loadDeviceFromMessage:(SLSSDPMessage *)message completeBlock:(void (^)(SLUPnPDevice *device))complete;

@end
