//
//  SSDPSearch.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-20.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLSSDPMessage.h"

@interface SLSSDPSearch : SLSSDPMessage

- (id)initWithTarget:(NSString *)aTarget;
- (id)initWithTarget:(NSString *)aTarget atHost:(NSString *)aHost;
- (id)initWithTarget:(NSString *)aTarget atHost:(NSString *)aHost waitTime:(NSUInteger)aWaitTime;
- (id)initWithHeaders:(SLHTTPHeaders *)someHeaders;

- (NSString *)target;
- (NSString *)host;
- (NSUInteger)waitTime;

+ (SLSSDPSearch *)search;
+ (SLSSDPSearch *)searchWithTarget:(NSString *)aTarget;
+ (SLSSDPSearch *)searchWithTarget:(NSString *)aTarget atHost:(NSString *)aHost;
+ (SLSSDPSearch *)searchWithTarget:(NSString *)aTarget atHost:(NSString *)aHost waitTime:(NSUInteger)aWaitTime;
+ (SLSSDPSearch *)searchWithMessage:(SLSSDPMessage *)aMessage;

@end
