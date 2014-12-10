//
//  UPnPDevice.h
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-03-23.
//

#import <Foundation/Foundation.h>

@class SLUPnPServices;
@class SLUPnPDevices;

@interface SLUPnPDevice : NSObject <NSXMLParserDelegate, NSCoding> {
    NSMutableString *_currentValue;
    NSMutableArray *_servicesArray;
    NSMutableArray *_devices;
}

@property (readonly) NSString *deviceType;
@property (readonly) NSString *friendlyName;
@property (readonly) NSString *UDN;
@property (readonly) NSURL *descriptionURL;
@property (readonly) SLUPnPServices *services;
@property (readonly) SLUPnPDevices *childDevices;
@property (readonly) SLUPnPDevice *parentDevice;

- (id)initWithDescriptionURL:(NSURL *)descriptionURL;
- (id)initWithParentDevice:(SLUPnPDevice *)parentDevice;

+ (SLUPnPDevice *)deviceInDevice:(SLUPnPDevice *)device withUDN:(NSString *)UDN;

@end
