
//
//  UPnPEventHandler.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-20.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLUPnPEventHandler.h"
#import "SLUPnPEvent.h"

@implementation SLUPnPEventHandler

@synthesize delegate;

- (NSData *)responseForRequest:(SLHTTPRequest *)aRequest
{
    return [[self responseStringForRequest:aRequest] dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)supportsHTTPMethod:(NSString *)anHTTPMethod
{
    return [anHTTPMethod isEqualToString:@"NOTIFY"];
}

- (NSString *)responseStringForRequest:(SLHTTPRequest *)aRequest
{
    if (![[aRequest HTTPMethod] isEqualToString:@"NOTIFY"]) {
        return @"HTTP/1.1 405 Method Not Allowed\r\n\r\n";
    }

    SLHTTPHeaders *headers = [aRequest allHTTPHeaderFields];

    NSString *nt = [headers valueForHeader:@"NT"];
    NSString *nts = [headers valueForHeader:@"NTS"];

    if (!nt || !nts) {
        return @"HTTP/1.1 400 Bad Request\r\n\r\n";
    }

    if ([self parseRequest:aRequest]) {
        return @"HTTP/1.1 200 OK\r\n\r\n";
    }

    return @"HTTP/1.1 412 Precondition Failed\r\n\r\n";
}

- (BOOL)parseRequest:(SLHTTPRequest *)aRequest
{
    SLHTTPHeaders *headers = [aRequest allHTTPHeaderFields];

    NSString *nt = [headers valueForHeader:@"NT"];
    NSString *nts = [headers valueForHeader:@"NTS"];
    NSString *sid = [headers valueForHeader:@"SID"];

    if (![nt isEqualToString:@"upnp:event"] || ![nts isEqualToString:@"upnp:propchange"] || !sid || [sid isEqualToString:@""] || ![self containsSubscriptionID:sid]) {
        return NO;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[aRequest HTTPBody]];

        SLUPnPEvent *event = [[SLUPnPEvent alloc] init];
        
        [parser setDelegate:event];
        [parser parse];

        NSDictionary *properties = [event properties];

        for (NSString *name in properties) {
            [[self delegate] didChangeVariable:name toValue:[properties objectForKey:name] forSubscriptionID:sid];
        }
    });

    return YES;
}

- (BOOL)containsSubscriptionID:(NSString *)anID
{
    return [[self delegate] containsEventSubscriptionForID:anID];
}

@end
