//
//  HTTPServer.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-22.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLHTTPServer.h"

@implementation SLHTTPServer

#pragma mark - Initialization

- (id)init
{
    return [self initWithPort:0];
}

- (id)initWithPort:(NSUInteger)port
{
    self = [super init];

    if (self) {
        _port = port;
    }

    return self;
}

#pragma mark - Properties

- (BOOL)isRunning
{
    return ![self.socket isDisconnected];
}

- (NSString *)host
{
    return [self.socket localHost];
}

- (NSUInteger)port
{
    return [self.socket localPort];
}

- (NSMutableSet *)requestHandlers
{
    if (!_requestHandlers) {
        _requestHandlers = [[NSMutableSet alloc] init];
    }
    
    return _requestHandlers;
}

- (dispatch_queue_t)socketDelegateQueue
{
    if (!_socketDelegateQueue) {
        _socketDelegateQueue = dispatch_queue_create("com.scottlangendyk.HTTPServerQueue", NULL);
    }
    
    return _socketDelegateQueue;
}

- (GCDAsyncSocket *)socket
{
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketDelegateQueue];
    }
    
    return _socket;
}

- (NSMutableSet *)connections
{
    if (!_connections) {
        _connections = [[NSMutableSet alloc] init];
    }

    return _connections;
}


#pragma mark - Server Lifecycle

- (void)addRequestHandler:(id <SLHTTPRequestHandler>)requestHandler
{
    [self.requestHandlers addObject:requestHandler];
}

- (void)removeRequestHandler:(id <SLHTTPRequestHandler>)requestHandler
{
    [self.requestHandlers removeObject:requestHandler];
}

- (BOOL)start
{
    if ([self isRunning]) {
        return YES;
    }

    [self.socket setDelegate:self];
    [self.socket acceptOnPort:self.port error:nil];

    return [self isRunning];
}

- (void)stop
{
    [self.socket setDelegate:nil];
    [self.socket disconnect];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    SLHTTPServerConnection *connection = [[SLHTTPServerConnection alloc] initWithSocket:newSocket andDelegate:self];

    // Maintain a reference to the connection object, so it isn't garbage collected
    [self.connections addObject:connection];

    [connection parseRequest];
}

#pragma mark - SLHTTPServerConnectionDelegate

- (void)connection:(SLHTTPServerConnection *)aConnection didParseRequest:(SLHTTPRequest *)aRequest
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSData *response = [@"HTTP/1.1 500 Internal Server Error\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];

        id <SLHTTPRequestHandler> handler = [self handlerForRequest:aRequest];

        if (handler) {
            response = [handler responseForRequest:aRequest];
        } else if ([self.requestHandlers count] > 0) {
            response = [@"HTTP/1.1 405 Method Not Allowed\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];
        }

        dispatch_async(self.socketDelegateQueue, ^ {
            [aConnection sendResponse:response];
        });
    });
}

- (void)connectionDidClose:(SLHTTPServerConnection *)aConnection
{
    [self.connections removeObject:aConnection];
}

- (id <SLHTTPRequestHandler>)handlerForRequest:(SLHTTPRequest *)aRequest
{
    for (id <SLHTTPRequestHandler> handler in self.requestHandlers) {
        if ([handler supportsHTTPMethod:[aRequest HTTPMethod]]) {
            return handler;
        }
    }

    return nil;
}

@end
