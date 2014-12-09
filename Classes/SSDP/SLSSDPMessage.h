//
//  SSDPMessage.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-20.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLHTTPHeaders.h"

@interface SLSSDPMessage : NSObject {
    SLHTTPHeaders *headers;
    NSString *startLine;
}

- (id)initWithStartLine:(NSString *)aStartLine headers:(SLHTTPHeaders *)someHeaders;

- (SLHTTPHeaders *)allHeaderFields;
- (NSString *)startLine;

- (NSData *)toData;
- (NSString *)toString;

+ (SLSSDPMessage *)messageFromData:(NSData *)data;

@end
