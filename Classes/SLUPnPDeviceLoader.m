//
//  SLUPnPDeviceLoader.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-10-27.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLUPnPDeviceLoader.h"
#import "AFNetworking.h"
#import "SLUPnPDeviceSerializer.h"

@implementation SLUPnPDeviceLoader

+ (SLUPnPDeviceLoader *)sharedLoader
{
    static SLUPnPDeviceLoader *sharedLoader = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedLoader = [[SLUPnPDeviceLoader alloc] init];
    });
    
    return sharedLoader;
}

- (void)loadDeviceFromMessage:(SLSSDPMessage *)message completeBlock:(void (^)(SLUPnPDevice *))complete
{
    NSString *UDN = [self UDNFromUSN:[[message allHeaderFields] valueForHeader:@"USN"]];
    
    SLUPnPDevice *device = [[self devicesMap] objectForKey:UDN];
    if (device) {
        return complete(device);
    }
    
    NSURL *location = [NSURL URLWithString:[[message allHeaderFields] valueForHeader:@"LOCATION"]];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:[[NSMutableURLRequest alloc] initWithURL:location]];
    
    [op setResponseSerializer:[SLUPnPDeviceSerializer serializer]];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        SLUPnPDevice *device = [SLUPnPDevice deviceInDevice:responseObject withUDN:UDN];
        
        [[self devicesMap] setObject:device forKey:UDN];
        
        complete(device);
    } failure:nil];

    [[NSOperationQueue mainQueue] addOperation:op];
}

- (NSMapTable *)devicesMap
{
    if (!_devicesMap) {
        _devicesMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    
    return _devicesMap;
}

- (NSString *)UDNFromUSN:(NSString *)USN
{
    NSRange range = [USN rangeOfString:@"::"];

    if (range.location == NSNotFound) {
        return USN;
    }

    return [USN substringToIndex:range.location];
}

@end
