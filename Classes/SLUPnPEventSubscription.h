//
//  UPnPEventSubscription.h
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-02-02.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLUPnPEventSubscription : NSObject {
    NSHTTPURLResponse *response;
    NSDate *expirationDate;
}

- (id)initWithResponse:(NSHTTPURLResponse *)aResponse;

- (NSString *)subscriptionId;
- (BOOL)isExpired;
- (NSUInteger)timeout;
- (NSDate *)expirationDate;

+ (NSDate *)parseTimeout:(NSString *)aTimeout;

@end
