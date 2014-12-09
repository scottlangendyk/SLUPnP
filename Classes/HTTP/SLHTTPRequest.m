//
//  HTTPRequest.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-22.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLHTTPRequest.h"

@implementation SLHTTPRequest

- (id)initWithMethod:(NSString *)aMethod URI:(NSString *)aURI headers:(SLHTTPHeaders *)requestHeaders body:(NSData *)requestBody
{
    self = [super init];

    if (self) {
        method = aMethod;
        headers = requestHeaders;
        body = requestBody;
        URI = aURI;
    }

    return self;
}

- (SLHTTPHeaders *)allHTTPHeaderFields
{
    return headers;
}

- (NSData *)HTTPBody
{
    return body;
}

- (NSString *)HTTPMethod
{
    return method;
}

- (NSString *)URI
{
    return URI;
}

@end
