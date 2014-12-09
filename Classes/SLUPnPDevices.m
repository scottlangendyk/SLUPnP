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

- (id)initWithDevices:(NSArray *)devices
{
    self = [super init];
    
    if (self) {
        _devices = devices;
    }
    
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _devices = [aDecoder decodeObjectForKey:@"devices"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_devices forKey:@"devices"];
}

- (NSArray *)allDevices
{
    return [[NSArray alloc] initWithArray:_devices];
}

- (SLUPnPDevice *)deviceWithUDN:(NSString *)UDN
{
    for (SLUPnPDevice *device in _devices) {
        if ([[device UDN] isEqualToString:UDN]) {
            return device;
        }
    }
    
    return nil;
}

- (NSSet *)devicesWithType:(NSString *)deviceType
{
    NSMutableSet *devicesSet = [[NSMutableSet alloc] init];
    
    for (SLUPnPDevice *device in _devices) {
        if ([[device deviceType] isEqualToString:deviceType]) {
            [devicesSet addObject:device];
        }
    }
    
    return devicesSet;
}

- (NSUInteger)count
{
    return [_devices count];
}

- (SLUPnPDevice *)deviceAtIndex:(NSUInteger)index
{
    return [_devices objectAtIndex:index];
}

@end
