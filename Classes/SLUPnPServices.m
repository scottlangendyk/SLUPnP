//
//  UPnPServices.m
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-10-01.
//
//

#import "SLUPnPServices.h"
#import "SLUPnPService.h"

@implementation SLUPnPServices

- (id)initWithServicesSet:(NSSet *)servicesSet
{
    self = [super init];
    
    if (self) {
        services = servicesSet;
    }
    
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        services = [aDecoder decodeObjectForKey:@"services"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:services forKey:@"services"];
}

- (NSSet *)allServices
{
    return [[NSSet alloc] initWithSet:services];
}

- (SLUPnPService *)serviceWithID:(NSString *)serviceID
{
    for (SLUPnPService *service in services) {
        if ([[service serviceId] isEqualToString:serviceID]) {
            return service;
        }
    }
    
    return nil;
}

- (NSSet *)servicesWithType:(NSString *)serviceType
{
    NSMutableSet *servicesSet = [[NSMutableSet alloc] init];
    
    for (SLUPnPService *service in services) {
        if ([[service serviceType] isEqualToString:serviceType]) {
            [servicesSet addObject:service];
        }
    }
    
    return servicesSet;
}

@end
