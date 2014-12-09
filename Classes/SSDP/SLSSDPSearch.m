//
//  SSDPSearch.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-20.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLSSDPSearch.h"
#import "SLHTTPHeaders.h"

@implementation SLSSDPSearch

- (id)init
{
    return [self initWithTarget:nil];
}

- (id)initWithTarget:(NSString *)aTarget
{
    return [self initWithTarget:aTarget atHost:@"239.255.255.250:1900"];
}

- (id)initWithTarget:(NSString *)aTarget atHost:(NSString *)aHost
{
    return [self initWithTarget:aTarget atHost:aHost waitTime:3];
}

- (id)initWithTarget:(NSString *)aTarget atHost:(NSString *)aHost waitTime:(NSUInteger)aWaitTime
{
    if (!aTarget) {
        aTarget = @"ssdp:all";
    }

    NSDictionary *headersDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:aHost, @"\"ssdp:discover\"", [NSString stringWithFormat:@"%lu", (unsigned long)aWaitTime], aTarget, nil] forKeys:[NSArray arrayWithObjects:@"HOST", @"MAN", @"MX", @"ST", nil]];

    return [self initWithHeaders:[[SLHTTPHeaders alloc] initWithHeadersDictionary:headersDictionary]];
}

- (id)initWithHeaders:(SLHTTPHeaders *)someHeaders
{
    return [super initWithStartLine:@"M-SEARCH * HTTP/1.1" headers:someHeaders];
}

- (NSString *)target
{
    return [headers valueForHeader:@"ST"];
}

- (NSString *)host
{
    return [headers valueForHeader:@"HOST"];
}

- (NSUInteger)waitTime
{
    return [[headers valueForHeader:@"MX"] integerValue];
}

+ (SLSSDPSearch *)search
{
    return [[SLSSDPSearch alloc] init];
}

+ (SLSSDPSearch *)searchWithTarget:(NSString *)aTarget
{
    return [[SLSSDPSearch alloc] initWithTarget:aTarget];
}

+ (SLSSDPSearch *)searchWithTarget:(NSString *)aTarget atHost:(NSString *)aHost
{
    return [[SLSSDPSearch alloc] initWithTarget:aTarget atHost:aHost];
}

+ (SLSSDPSearch *)searchWithTarget:(NSString *)aTarget atHost:(NSString *)aHost waitTime:(NSUInteger)aWaitTime
{
    return [[SLSSDPSearch alloc] initWithTarget:aTarget atHost:aHost waitTime:aWaitTime];
}

+ (SLSSDPSearch *)searchWithMessage:(SLSSDPMessage *)aMessage
{
    return [[SLSSDPSearch alloc] initWithHeaders:[aMessage allHeaderFields]];
}

@end
