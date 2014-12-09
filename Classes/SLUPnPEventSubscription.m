//
//  UPnPEventSubscription.m
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-02-02.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLUPnPEventSubscription.h"

@implementation SLUPnPEventSubscription

- (id)initWithResponse:(NSHTTPURLResponse *)aResponse
{
    self = [super init];

    if (self) {
        response = aResponse;
    }

    return self;
}

- (NSString *)subscriptionId
{
    return [[response allHeaderFields] objectForKey:@"SID"];
}

- (BOOL)isExpired
{
    NSDate *date = [NSDate date];

    if (date == [date laterDate:[self expirationDate]]) {
        return YES;
    }

    return NO;
}

- (NSUInteger)timeout
{
    NSTimeInterval interval = (NSUInteger)[[self expirationDate] timeIntervalSinceNow];

    if (interval > 0) {
        return interval;
    }

    return 0;
}

- (NSDate *)expirationDate
{
    if (!expirationDate) {
        expirationDate = [SLUPnPEventSubscription parseTimeout:[[response allHeaderFields] objectForKey:@"TIMEOUT"]];
    }

    return expirationDate;
}

+ (NSDate *)parseTimeout:(NSString *)aTimeout
{
    // Timeout is in format Second-#
    return [NSDate dateWithTimeIntervalSinceNow:[[aTimeout substringFromIndex:7] integerValue]];
}

@end
