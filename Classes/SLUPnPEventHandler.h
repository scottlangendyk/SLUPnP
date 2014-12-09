//
//  UPnPEventHandler.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-20.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLHTTPServer.h"

@class SLUPnPEventHandler;

@protocol SLUPnPEventHandlerDelegate <NSObject>

- (void)didChangeVariable:(NSString *)aVariable toValue:(NSString *)aValue forSubscriptionID:(NSString *)anID;
- (BOOL)containsEventSubscriptionForID:(NSString *)aSubscriptionID;

@end

@interface SLUPnPEventHandler : NSObject <SLHTTPRequestHandler>

@property id <SLUPnPEventHandlerDelegate> delegate;

@end
