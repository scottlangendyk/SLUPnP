//
//  SSDPResponse.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-02-02.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLSSDPResponse.h"

@implementation SLSSDPResponse

- (id)initWithHeaders:(SLHTTPHeaders *)someHeaders
{
    return [super initWithStartLine:@"HTTP/1.1 200 OK" headers:someHeaders];
}

- (NSUInteger)maxAge
{
    return [[[[self allHeaderFields] valueForHeader:@"CACHE-CONTROL"] substringFromIndex:8] integerValue];
}

- (NSString *)location
{
    return [[self allHeaderFields] valueForHeader:@"LOCATION"];
}

- (NSString *)server
{
    return [[self allHeaderFields] valueForHeader:@"SERVER"];
}

- (NSString *)searchTarget
{
    return [[self allHeaderFields] valueForHeader:@"ST"];
}

- (NSString *)USN
{
    return [[self allHeaderFields] valueForHeader:@"USN"];
}

- (NSUInteger)bootID
{
    return [[[self allHeaderFields] valueForHeader:@"BOOTID.UPNP.ORG"] integerValue];
}

+ (SLSSDPResponse *)responseWithMessage:(SLSSDPMessage *)aMessage
{
    return [[SLSSDPResponse alloc] initWithHeaders:[aMessage allHeaderFields]];
}

@end
