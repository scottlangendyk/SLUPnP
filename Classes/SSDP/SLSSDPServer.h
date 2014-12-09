//
//  SSDPServer.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-20.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLSSDPMessage.h"
#import "GCDAsyncUdpSocket.h"
#import "SLSSDPNotification.h"
#import "SLSSDPResponse.h"
#import "SLSSDPSearch.h"

@class SLSSDPServer;

@protocol SLSSDPServerObserver <NSObject>

@optional

- (void)ssdpServer:(SLSSDPServer *)server didReceiveNotification:(SLSSDPNotification *)notification fromHost:(NSString *)host onPort:(uint16_t)port;
- (void)ssdpServer:(SLSSDPServer *)server didReceiveResponse:(SLSSDPResponse *)response fromHost:(NSString *)host onPort:(uint16_t)port;
- (void)ssdpServer:(SLSSDPServer *)server didReceiveSearch:(SLSSDPSearch *)search fromHost:(NSString *)host onPort:(uint16_t)port;

@end

@interface SLSSDPServer : NSObject <GCDAsyncUdpSocketDelegate> {
    GCDAsyncUdpSocket *_listenSocket;
    GCDAsyncUdpSocket *_sendSocket;
    dispatch_queue_t _delegateQueue;

    NSMutableSet *_observers;
}

- (void)sendMessage:(SLSSDPMessage *)message;
- (void)sendMessage:(SLSSDPMessage *)message toHost:(NSString *)host onPort:(uint16_t)port;

- (void)addObserver:(id<SLSSDPServerObserver>)observer;
- (void)removeObserver:(id<SLSSDPServerObserver>)observer;

+ (SLSSDPServer *)sharedServer;

@end
