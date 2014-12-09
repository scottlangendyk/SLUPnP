//
//  SSDPNotification.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-02-02.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLSSDPNotification.h"

@implementation SLSSDPNotification

- (id)initWithHeaders:(SLHTTPHeaders *)someHeaders
{
    return [super initWithStartLine:@"NOTIFY * HTTP/1.1" headers:someHeaders];
}

- (NSString *)host
{
    return [[self allHeaderFields] valueForKey:@"HOST"];
}

- (NSString *)type
{
    return [[self allHeaderFields] valueForKey:@"NT"];
}

- (NSString *)subType
{
    return [[self allHeaderFields] valueForKey:@"NTS"];
}

- (NSString *)USN
{
    return [[self allHeaderFields] valueForKey:@"USN"];
}

- (NSUInteger)bootID
{
    return [[[self allHeaderFields] valueForKey:@"BOOTID.UPNP.ORG"] integerValue];
}

- (NSUInteger)configID
{
    return [[[self allHeaderFields] valueForKey:@"CONFIGID.UPNP.ORG"] integerValue];
}

+ (SLSSDPNotification *)notificationWithMessage:(SLSSDPMessage *)aMessage
{
    return [[SLSSDPNotification alloc] initWithHeaders:[aMessage allHeaderFields]];
}

@end
