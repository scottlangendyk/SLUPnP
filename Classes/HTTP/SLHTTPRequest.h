//
//  HTTPRequest.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-22.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLHTTPHeaders.h"

@interface SLHTTPRequest : NSObject {
    SLHTTPHeaders *headers;
    NSString *URI;
    NSData *body;
    NSString *method;
}

- (id)initWithMethod:(NSString *)aMethod URI:(NSString *)aURI headers:(SLHTTPHeaders *)requestHeaders body:(NSData *)requestBody;

- (SLHTTPHeaders *)allHTTPHeaderFields;
- (NSData *)HTTPBody;
- (NSString *)HTTPMethod;
- (NSString *)URI;

@end
