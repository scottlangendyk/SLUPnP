//
//  HTTPHeaders.h
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-22.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLHTTPHeaders : NSObject <NSFastEnumeration> {
    NSDictionary *headers;
    NSArray *transferEncodings;
}

- (id)initWithHeadersDictionary:(NSDictionary *)headersDictionary;

- (NSString *)valueForHeader:(NSString *)header;

- (NSEnumerator *)objectEnumerator;

/**
 * Convenience method for parsing the "Transfer-Encoding" header field. Will return an
 * empty NSArray if the header is missing.
 */
- (NSArray *)transferEncoding;

+ (SLHTTPHeaders *)headersFromData:(NSData *)data;
+ (SLHTTPHeaders *)headersFromString:(NSString *)string;

@end
