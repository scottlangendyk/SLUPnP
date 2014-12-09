//
//  UPnPDevices.h
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-10-01.
//
//

#import <Foundation/Foundation.h>

@class SLUPnPDevice;

@interface SLUPnPDevices : NSObject <NSCoding> {
    NSSet *devices;
}

- (id)initWithDevicesSet:(NSSet *)devicesSet;

- (NSSet *)allDevices;

- (SLUPnPDevice *)deviceWithUDN:(NSString *)UDN;
- (NSSet *)devicesWithType:(NSString *)deviceType;

@end
