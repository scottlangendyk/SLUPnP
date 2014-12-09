//
//  UPnPActionResponse.m
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-03-20.
//
//

#import "SLUPnPActionResponse.h"

@implementation SLUPnPActionResponse

@synthesize responseProperties;

- (id)initWithActionName:(NSString *)anActionName
{
    self = [super init];

    if (self) {
        actionName = anActionName;
    }

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:[self bodyElementName]]) {
        currentProperties = [[NSMutableDictionary alloc] init];
    }

    currentValue = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:[self bodyElementName]]) {
        responseProperties = [NSDictionary dictionaryWithDictionary:currentProperties];
    }

    [currentProperties setObject:[[NSString alloc] initWithString:currentValue] forKey:elementName];
}

- (NSString *)bodyElementName
{
    return [NSString stringWithFormat:@"Body.%@Response", actionName];
}

@end
