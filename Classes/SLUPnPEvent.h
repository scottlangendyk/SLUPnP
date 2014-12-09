//
//  UPnPEvent.h
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-03-23.
//

#import <Foundation/Foundation.h>

@interface SLUPnPEvent : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentValue;
    NSMutableDictionary *currentProperties;
}

@property (readonly) NSDictionary *properties;

@end
