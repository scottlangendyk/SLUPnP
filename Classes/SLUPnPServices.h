//
//  UPnPServices.h
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-10-01.
//
//

#import <Foundation/Foundation.h>

@class SLUPnPService;

@interface SLUPnPServices : NSObject <NSCoding> {
    NSSet *services;
}

- (id)initWithServicesSet:(NSSet *)servicesSet;

- (NSSet *)allServices;

- (SLUPnPService *)serviceWithID:(NSString *)serviceID;
- (NSSet *)servicesWithType:(NSString *)serviceType;

@end
