//
//  UPnPDevices.m
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-10-01.
//
//

#import "SLUPnPDevices.h"
#import "SLUPnPDevice.h"

@implementation SLUPnPDevices

- (id)initWithDevicesSet:(NSSet *)devicesSet
{
    self = [super init];
    
    if (self) {
        devices = devicesSet;
    }
    
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        devices = [aDecoder decodeObjectForKey:@"devices"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:devices forKey:@"devices"];
}

- (NSSet *)allDevices
{
    return [[NSSet alloc] initWithSet:devices];
}

- (SLUPnPDevice *)deviceWithUDN:(NSString *)UDN
{
    for (SLUPnPDevice *device in devices) {
        if ([[device UDN] isEqualToString:UDN]) {
            return device;
        }
    }
    
    return nil;
}

- (NSSet *)devicesWithType:(NSString *)deviceType
{
    NSMutableSet *devicesSet = [[NSMutableSet alloc] init];
    
    for (SLUPnPDevice *device in devices) {
        if ([[device deviceType] isEqualToString:deviceType]) {
            [devicesSet addObject:device];
        }
    }
    
    return devicesSet;
}

@end
