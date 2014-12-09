//
//  SSDPServer.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-20.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLSSDPServer.h"

@implementation SLSSDPServer

- (void)listen
{
    if (![self.listenSocket isClosed]) {
        return;
    }

    [self.listenSocket setDelegate:self delegateQueue:self.delegateQueue];
    [self.listenSocket bindToPort:1900 error:nil];
    [self.listenSocket enableBroadcast:YES error:nil];
    [self.listenSocket joinMulticastGroup:@"239.255.255.250" error:nil];
    [self.listenSocket beginReceiving:nil];
}

- (GCDAsyncUdpSocket *)listenSocket
{
    if (!_listenSocket) {
        _listenSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    }
    
    return _listenSocket;
}

- (GCDAsyncUdpSocket *)sendSocket
{
    if (!_sendSocket) {
        _sendSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    }
    
    return _sendSocket;
}

- (dispatch_queue_t)delegateQueue
{
    if (!_delegateQueue) {
        _delegateQueue = dispatch_queue_create("com.scottlangendyk.SSDPServerDelegateQueue", NULL);
    }

    return _delegateQueue;
}

- (void)stop
{
    [self.listenSocket setDelegate:nil];
    [self.listenSocket close];

    [self.sendSocket setDelegate:nil];
    [self.sendSocket closeAfterSending];
}

- (void)sendMessage:(SLSSDPMessage *)message
{
    [self sendMessage:message toHost:@"239.255.255.250" onPort:1900];
}

- (void)sendMessage:(SLSSDPMessage *)message toHost:(NSString *)host onPort:(uint16_t)port
{
    if ([self.sendSocket isClosed]) {
        [self.sendSocket setDelegate:self];
        [self.sendSocket bindToPort:0 error:nil];
        [self.sendSocket enableBroadcast:YES error:nil];
        [self.sendSocket beginReceiving:nil];
    }

    [self.sendSocket sendData:[message toData] toHost:host port:port withTimeout:30 tag:0];
}

- (void)addObserver:(id<SLSSDPServerObserver>)anObserver
{
    [self.observers addObject:anObserver];
    [self listen];
}

- (NSMutableSet *)observers
{
    if (!_observers) {
        _observers = [[NSMutableSet alloc] init];
    }
    
    return _observers;
}

- (void)removeObserver:(id<SLSSDPServerObserver>)observer
{
    [self.observers removeObject:observer];

    if ([self.observers count] == 0) {
        [self stop];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    SLSSDPMessage *message = [SLSSDPMessage messageFromData:data];

    NSString *host = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];

    if ([[message startLine] isEqualToString:@"NOTIFY * HTTP/1.1"]) {
        SLSSDPNotification *notification = [SLSSDPNotification notificationWithMessage:message];

        for (id observer in self.observers) {
            if ([observer respondsToSelector:@selector(ssdpServer:didReceiveNotification:fromHost:onPort:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [observer ssdpServer:self didReceiveNotification:notification fromHost:host onPort:port];
                });
            }
        }
    } else if ([[message startLine] isEqualToString:@"HTTP/1.1 200 OK"]) {
        SLSSDPResponse *response = [SLSSDPResponse responseWithMessage:message];

        for (id observer in self.observers) {
            if ([observer respondsToSelector:@selector(ssdpServer:didReceiveResponse:fromHost:onPort:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [observer ssdpServer:self didReceiveResponse:response fromHost:host onPort:port];
                });
            }
        }
    } else if ([[message startLine] isEqualToString:@"M-SEARCH * HTTP/1.1"]) {
        SLSSDPSearch *search = [SLSSDPSearch searchWithMessage:message];

        for (id observer in self.observers) {
            if ([observer respondsToSelector:@selector(ssdpServer:didReceiveSearch:fromHost:onPort:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [observer ssdpServer:self didReceiveSearch:search fromHost:host onPort:port];
                });
            }
        }
    }
}

+ (SLSSDPServer *)sharedServer
{
    static SLSSDPServer *sharedServer = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServer = [[SLSSDPServer alloc] init];
    });
    
    return sharedServer;
}

@end
