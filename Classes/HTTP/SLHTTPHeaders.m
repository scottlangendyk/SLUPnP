//
//  HTTPHeaders.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-22.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLHTTPHeaders.h"

@implementation SLHTTPHeaders

- (id)initWithHeadersDictionary:(NSDictionary *)headersDictionary
{
    self = [super init];

    if (self) {
        NSMutableDictionary *caseInsensitiveHeadersDictionary = [[NSMutableDictionary alloc] init];

        for (NSString *key in headersDictionary) {
            [caseInsensitiveHeadersDictionary setObject:[headersDictionary valueForKey:key] forKey:[key capitalizedString]];
        }

        headers = [NSDictionary dictionaryWithDictionary:caseInsensitiveHeadersDictionary];
    }

    return self;
}

- (NSString *)valueForHeader:(NSString *)header
{
    return [headers valueForKey:[header capitalizedString]];
}

- (id)valueForKey:(NSString *)key
{
    return [self valueForHeader:key];
}

- (NSEnumerator *)objectEnumerator
{
    return [headers objectEnumerator];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    return [headers countByEnumeratingWithState:state objects:buffer count:len];
}

+ (SLHTTPHeaders *)headersFromData:(NSData *)data
{
    return [SLHTTPHeaders headersFromString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

- (NSArray *)transferEncoding
{
    // RFC 2616 [14.41] Transfer-Encoding
    //
    // The Transfer-Encoding general-header field indicates what (if any) type of transformation has been applied to the message body in
    // order to safely transfer it between the sender and the recipient. This differs from the content-coding in that the transfer-coding
    // is a property of the message, not of the entity.
    //
    //    Transfer-Encoding       = "Transfer-Encoding" ":" 1#transfer-coding
    //
    // Transfer-codings are defined in section 3.6. An example is:
    //
    //    Transfer-Encoding: chunked
    //
    // If multiple encodings have been applied to an entity, the transfer- codings MUST be listed in the order in which they were applied.
    // Additional information about the encoding parameters MAY be provided by other entity-header fields not defined by this specification.
    //
    // Many older HTTP/1.0 applications do not understand the Transfer- Encoding header.


    // RFC 2616 [3.6] Transfer Codings
    //
    // Transfer-coding values are used to indicate an encoding transformation that has been, can be, or may need to be applied to an
    // entity-body in order to ensure "safe transport" through the network. This differs from a content coding in that the transfer-coding
    // is a property of the message, not of the original entity.
    //
    //     transfer-coding         = "chunked" | transfer-extension
    //     transfer-extension      = token *( ";" parameter )
    //
    // Parameters are in the form of attribute/value pairs.
    //
    //     parameter               = attribute "=" value
    //     attribute               = token
    //     value                   = token | quoted-string
    //
    // All transfer-coding values are case-insensitive. HTTP/1.1 uses transfer-coding values in the TE header field (section 14.39) and in the
    // Transfer-Encoding header field (section 14.41).
    //
    // Whenever a transfer-coding is applied to a message-body, the set of transfer-codings MUST include "chunked", unless the message is terminated
    // by closing the connection. When the "chunked" transfer- coding is used, it MUST be the last transfer-coding applied to the message-body. The
    // "chunked" transfer-coding MUST NOT be applied more than once to a message-body. These rules allow the recipient to determine the transfer-length
    // of the message (section 4.4).
    //
    // Transfer-codings are analogous to the Content-Transfer-Encoding values of MIME [7], which were designed to enable safe transport of binary data
    // over a 7-bit transport service. However, safe transport has a different focus for an 8bit-clean transfer protocol. In HTTP, the only unsafe
    // characteristic of message-bodies is the difficulty in determining the exact body length (section 7.2.2), or the desire to encrypt data over a
    // shared transport.
    //
    // The Internet Assigned Numbers Authority (IANA) acts as a registry for transfer-coding value tokens. Initially, the registry contains the following
    // tokens: "chunked" (section 3.6.1), "identity" (section 3.6.2), "gzip" (section 3.5), "compress" (section 3.5), and "deflate" (section 3.5).
    //
    // New transfer-coding value tokens SHOULD be registered in the same way as new content-coding value tokens (section 3.5).
    //
    // A server which receives an entity-body with a transfer-coding it does not understand SHOULD return 501 (Unimplemented), and close the connection.
    // A server MUST NOT send transfer-codings to an HTTP/1.0 client.


    // RFC 2616 [2.1] Augmented BNF
    //
    // A construct "#" is defined, similar to "*", for defining lists of elements. The full form is "<n>#<m>element" indicating at least <n> and at most <m> elements,
    // each separated by one or more commas (",") and OPTIONAL linear white space (LWS). This makes the usual form of lists very easy; a rule such as
    //
    //     ( *LWS element *( *LWS "," *LWS element ))
    //
    // can be shown as
    //
    //     1#element
    //
    // Wherever this construct is used, null elements are allowed, but do not contribute to the count of elements present. That is, "(element), , (element) " is permitted,
    // but counts as only two elements. Therefore, where at least one element is required, at least one non-null element MUST be present. Default values are 0 and infinity
    // so that "#element" allows any number, including zero; "1#element" requires at least one; and "1#2element" allows one or two.


    if (!transferEncodings) {
        NSString *encoding = [self valueForHeader:@"Transfer-Encoding"];

        if (encoding) {
            transferEncodings = [NSArray arrayWithObject:encoding];
        } else {
            transferEncodings = [NSArray array];
        }
    }

    return transferEncodings;
}

+ (SLHTTPHeaders *)headersFromString:(NSString *)string
{
    NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] init];

    // Current field name and value during loop
    NSMutableString *fieldName = [NSMutableString stringWithString:@""];
    NSMutableString *fieldValue = [NSMutableString stringWithString:@""];

    // Headers are allowed over multiple lines, so iterate
    NSArray *lines = [string componentsSeparatedByString:@"\r\n"];
    NSEnumerator *enumerator = [lines objectEnumerator];

    NSString *line;

    BOOL foundFieldName = NO;

    while (line = [enumerator nextObject]) {
        BOOL resolveHeaders = YES;
        BOOL newLine = YES;
        BOOL trimLeading = NO;

        while (resolveHeaders) {
            // Determine if line starts with whitespace
            NSInteger i = 0;

            while ((i < [line length]) && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[line characterAtIndex:i]]) {
                i++;
            }

            // Headers can continue across multiple lines, if they start with whitespace
            if (newLine && i > 0) {
                newLine = NO;
                trimLeading = YES;
            }

            // Pretend there was no whitespace for easier prcoessing
            if (trimLeading) {
                line = [line substringFromIndex:i];
                trimLeading = NO;
            }

            // If we're on a new line and have found a field name add it to the dictionary
            if (newLine && foundFieldName) {
                NSString *value = [NSString stringWithString:fieldValue];

                // Trim leading whitespace from field value
                i = [value length] - 1;

                while (i >= 0 && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[value characterAtIndex:i]]) {
                    i--;
                }

                if (i > 0) {
                    value = [value substringToIndex:i+1];
                }

                [headersDictionary setObject:value forKey:fieldName];

                fieldValue = [NSMutableString stringWithString:@""];
                fieldName = [NSMutableString stringWithString:@""];

                foundFieldName = NO;
            }

            if (!foundFieldName) {
                // Find seperator for field and value
                NSRange range = [line rangeOfString:@":"];

                if (range.location != NSNotFound) {
                    [fieldName appendString:[line substringToIndex:range.location]];

                    line = [line substringFromIndex:range.location + range.length];

                    trimLeading = YES;
                    foundFieldName = YES;
                } else {
                    [fieldName appendString:line];
                    resolveHeaders = NO;
                }
            } else {
                [fieldValue appendString:line];
                resolveHeaders = NO;
            }

            newLine = NO;
        }
    }

    return [[SLHTTPHeaders alloc] initWithHeadersDictionary:headersDictionary];
}

@end
