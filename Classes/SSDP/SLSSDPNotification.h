//
//  SSDPNotification.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-02-02.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLSSDPMessage.h"

@interface SLSSDPNotification : SLSSDPMessage

- (id)initWithHeaders:(SLHTTPHeaders *)someHeaders;

- (NSString *)host;
- (NSString *)type;
- (NSString *)subType;
- (NSString *)USN;
- (NSUInteger)bootID;
- (NSUInteger)configID;

+ (SLSSDPNotification *)notificationWithMessage:(SLSSDPMessage *)aMessage;

@end
