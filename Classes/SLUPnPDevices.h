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
    NSArray *_devices;
}

- (id)initWithDevices:(NSArray *)devices;

- (NSArray *)allDevices;

- (SLUPnPDevice *)deviceWithUDN:(NSString *)UDN;
- (NSSet *)devicesWithType:(NSString *)deviceType;

- (NSUInteger)count;
- (SLUPnPDevice *)deviceAtIndex:(NSUInteger)index;

@end
