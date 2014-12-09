//
//  SLUPnPDeviceFinder.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-11-26.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLUPnPDeviceFinder.h"
#import "SLUPnPDeviceLoader.h"

@implementation SLUPnPDeviceFinder

@synthesize target = _target;
@synthesize delegate = _delegate;
@synthesize searching = _searching;
@synthesize loader = _loader;
@synthesize searchInterval = _searchInterval;

#pragma mark - Initialization

- (id)init
{
    return [self initWithTarget:@"ssdp:all"];
}

- (id)initWithTarget:(NSString *)target
{
    self = [super init];
    
    if (self) {
        _target = target;
    }
    
    return self;
}

#pragma mark - Accessors

- (SLSSDPServer *)ssdpServer
{
    return [SLSSDPServer sharedServer];
}

- (SLUPnPDeviceLoader *)loader
{
    if (!_loader) {
        _loader = [SLUPnPDeviceLoader sharedLoader];
    }
    
    return _loader;
}

- (void)setSearching:(BOOL)searching
{
    if (searching == _searching) {
        return;
    }
    
    _searching = searching;
}

- (NSTimeInterval)searchInterval
{
    if (!_searchInterval) {
        _searchInterval = 1.0;
    }
    
    return _searchInterval;
}

#pragma mark - Searching

- (void)startSearching
{
    if ([self isSearching]) {
        return;
    }
    
    _devices = [[NSMutableSet alloc] init];
    
    [[self ssdpServer] addObserver:self];
    [self setSearching:YES];
    [self search];
}

- (void)stopSearching
{
    if (![self isSearching]) {
        return;
    }
    
    [self setSearching:NO];
    [[self ssdpServer] removeObserver:self];
}

- (void)search
{
    if (![self isSearching]) {
        return;
    }
    
    [[self ssdpServer] sendMessage:[SLSSDPSearch searchWithTarget:[self target]]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [self searchInterval] * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self search];
    });
}

- (void)parseMessage:(SLSSDPMessage *)message
{
    if (![[[message allHeaderFields] valueForHeader:@"ST"] isEqualToString:[self target]]) {
        return;
    }
    
    [[self loader] loadDeviceFromMessage:message completeBlock:^(SLUPnPDevice *device) {
        [self didFindDevice:device];
    }];
}

- (void)didFindDevice:(SLUPnPDevice *)device
{
    if (![self isSearching]) {
        return;
    }
    
    if ([_devices containsObject:device]) {
        return;
    }
    
    [_devices addObject:device];
    
    [[self delegate] deviceFinder:self didFindDevice:device];
}

#pragma mark - SLSSDPServerObserver

- (void)ssdpServer:(SLSSDPServer *)server didReceiveResponse:(SLSSDPResponse *)response fromHost:(NSString *)host onPort:(uint16_t)port
{
    if (![self isSearching] || server != [self ssdpServer]) {
        return;
    }
    
    [self parseMessage:response];
}

- (void)ssdpServer:(SLSSDPServer *)server didReceiveNotification:(SLSSDPNotification *)notification fromHost:(NSString *)host onPort:(uint16_t)port
{
    if (![self isSearching] || server != [self ssdpServer]) {
        return;
    }
    
    [self parseMessage:notification];
}

@end
