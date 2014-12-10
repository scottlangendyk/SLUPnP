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
    NSArray *_services;
}

- (id)initWithServices:(NSArray *)services;

- (NSArray *)allServices;

- (SLUPnPService *)serviceWithID:(NSString *)serviceID;
- (NSSet *)servicesWithType:(NSString *)serviceType;

- (NSUInteger)count;
- (SLUPnPService *)serviceAtIndex:(NSUInteger)index;

@end
