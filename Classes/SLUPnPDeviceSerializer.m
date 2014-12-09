//
//  AFUPnPDeviceSerializer.m
//  Pods
//
//  Created by Scott Langendyk on 2014-03-24.
//
//

#import "SLUPnPDeviceSerializer.h"
#import "SLUPnPDevice.h"

@implementation SLUPnPDeviceSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    NSXMLParser *parser = [super responseObjectForResponse:response data:data error:error];

    if (!parser) {
        return nil;
    }

    SLUPnPDevice *device = [[SLUPnPDevice alloc] initWithDescriptionURL:[response URL]];

    [parser setDelegate:device];
    [parser parse];

    return device;
}

@end
