//
//  SSDPResponse.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-02-02.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLSSDPMessage.h"

@interface SLSSDPResponse : SLSSDPMessage

- (id)initWithHeaders:(SLHTTPHeaders *)someHeaders;

- (NSUInteger)maxAge;
- (NSString *)location;
- (NSString *)server;
- (NSString *)searchTarget;
- (NSString *)USN;
- (NSUInteger)bootID;

+ (SLSSDPResponse *)responseWithMessage:(SLSSDPMessage *)aMessage;

@end
