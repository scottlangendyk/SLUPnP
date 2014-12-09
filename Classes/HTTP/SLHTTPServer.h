//
//  HTTPServer.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-22.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "SLHTTPServerConnection.h"
#import "SLHTTPRequest.h"

@class SLHTTPServer;

@protocol SLHTTPRequestHandler <NSObject>

- (NSData *)responseForRequest:(SLHTTPRequest *)aRequest;
- (BOOL)supportsHTTPMethod:(NSString *)anHTTPMethod;

@end

@interface SLHTTPServer : NSObject <GCDAsyncSocketDelegate, SLHTTPServerConnectionDelegate> {
    GCDAsyncSocket *_socket;
    NSMutableSet *_connections;
    dispatch_queue_t _socketDelegateQueue;
    NSMutableSet *_requestHandlers;
    NSUInteger _port;
}

- (id)initWithPort:(NSUInteger)port;

- (BOOL)start;
- (void)stop;

- (BOOL)isRunning;

- (NSString *)host;
- (NSUInteger)port;

- (void)addRequestHandler:(id <SLHTTPRequestHandler>)requestHandler;
- (void)removeRequestHandler:(id <SLHTTPRequestHandler>)requestHandler;

@end
