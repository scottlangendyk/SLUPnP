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

- (id)initWithServices:(NSArray *)services
{
    self = [super init];
    
    if (self) {
        _services = services;
    }
    
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _services = [aDecoder decodeObjectForKey:@"services"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_services forKey:@"services"];
}

- (NSArray *)allServices
{
    return [[NSArray alloc] initWithArray:_services];
}

- (SLUPnPService *)serviceWithID:(NSString *)serviceID
{
    for (SLUPnPService *service in _services) {
        if ([[service serviceId] isEqualToString:serviceID]) {
            return service;
        }
    }
    
    return nil;
}

- (NSSet *)servicesWithType:(NSString *)serviceType
{
    NSMutableSet *servicesSet = [[NSMutableSet alloc] init];
    
    for (SLUPnPService *service in _services) {
        if ([[service serviceType] isEqualToString:serviceType]) {
            [servicesSet addObject:service];
        }
    }
    
    return servicesSet;
}

- (NSUInteger)count
{
    return [_services count];
}

- (SLUPnPService *)serviceAtIndex:(NSUInteger)index
{
    return [_services objectAtIndex:index];
}

@end
