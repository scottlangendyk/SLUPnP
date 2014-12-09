//
//  SSDPMessage.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-20.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLSSDPMessage.h"

@implementation SLSSDPMessage

- (id)initWithStartLine:(NSString *)aStartLine headers:(SLHTTPHeaders *)someHeaders
{
    self = [super init];

    if (self) {
        startLine = aStartLine;
        headers = someHeaders;
    }

    return self;
}

- (SLHTTPHeaders *)allHeaderFields
{
    return headers;
}

- (NSString *)startLine
{
    return startLine;
}

- (NSData *)toData
{
    return [[self toString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)toString
{
    NSMutableString *data = [NSMutableString stringWithFormat:@"%@\r\n", [self startLine]];

    for (id header in headers) {
        [data appendString:[NSString stringWithFormat:@"%@: %@\r\n", header, [headers valueForHeader:header]]];
    }

    [data appendString:@"\r\n"];

    return [NSString stringWithString:data];
}

- (NSString *)description
{
    return [self toString];
}

+ (SLSSDPMessage *)messageFromData:(NSData *)data
{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSRange range = [message rangeOfString:@"\r\n"];

    if (range.location != NSNotFound) {
        NSString *startLine = [message substringToIndex:range.location];
        SLHTTPHeaders *headers = [SLHTTPHeaders headersFromString:[message substringFromIndex:range.location + range.length]];

        return [[SLSSDPMessage alloc] initWithStartLine:startLine headers:headers];
    }

    return nil;
}

@end
