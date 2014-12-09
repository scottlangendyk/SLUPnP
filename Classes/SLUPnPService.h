//
//  UPnPService.h
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-03-23.
//

#import <Foundation/Foundation.h>

@class SLUPnPDevice;

@interface SLUPnPService : NSObject <NSXMLParserDelegate, NSCoding> {
    NSMutableString *currentValue;
}

@property (readonly) NSString *serviceType;
@property (readonly) NSString *serviceId;
@property (readonly) NSURL *SCPDURL;
@property (readonly) NSURL *controlURL;
@property (readonly) NSURL *eventSubURL;
@property (readonly) SLUPnPDevice *device;

- (id)initWithDevice:(SLUPnPDevice *)aDevice;

- (NSURLRequest *)invokeAction:(NSString *)actionName;
- (NSURLRequest *)invokeAction:(NSString *)actionName withParameters:(NSDictionary *)actionParameters;

- (NSURLRequest *)subscribeWithCallback:(NSURL *)aCallback;
- (NSURLRequest *)renewWithId:(NSString *)aSubscriptionId;
- (NSURLRequest *)unsubscribeWithId:(NSString *)aSubscriptionId;

@end
