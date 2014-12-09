//
//  HTTPServerConnection.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-22.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "SLHTTPRequest.h"
#import "SLHTTPHeaders.h"

@class SLHTTPServerConnection;


@protocol SLHTTPServerConnectionDelegate <NSObject>

@optional

- (void)connection:(SLHTTPServerConnection *)aConnection didParseRequest:(SLHTTPRequest *)aRequest;
- (void)connectionDidClose:(SLHTTPServerConnection *)aConnection;

@end


@interface SLHTTPServerConnection : NSObject <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *socket;

    SLHTTPHeaders *headers;
    NSMutableData *body;
    NSMutableData *headerData;

    NSString *method;
    NSString *URI;

    NSData *lastData;

    SLHTTPRequest *request;
}

@property (assign) id <SLHTTPServerConnectionDelegate> delegate;

- (id)initWithSocket:(GCDAsyncSocket *)aSocket andDelegate:(id <SLHTTPServerConnectionDelegate>)aDelegate;

- (void)parseRequest;
- (void)sendResponse:(NSData *)aResponse;
- (void)close;

@end
