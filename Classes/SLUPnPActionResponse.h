//
//  UPnPActionResponse.h
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-03-20.
//
//

#import <Foundation/Foundation.h>

@interface SLUPnPActionResponse : NSObject <NSXMLParserDelegate> {
    NSString *actionName;
    NSMutableDictionary *currentProperties;
    NSMutableString *currentValue;
}

@property (readonly) NSDictionary *responseProperties;

- (id)initWithActionName:(NSString *)anActionName;

@end
