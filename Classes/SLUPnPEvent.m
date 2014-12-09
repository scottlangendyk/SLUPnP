//
//  UPnPEvent.m
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-03-23.
//

#import "SLUPnPEvent.h"

@implementation SLUPnPEvent

@synthesize properties;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"e:propertyset"]) {
        currentProperties = [[NSMutableDictionary alloc] init];
    }

    currentValue = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"e:property"]) {
        return;
    }

    if ([elementName isEqualToString:@"e:propertyset"]) {
        properties = [NSDictionary dictionaryWithDictionary:currentProperties];
    }

    [currentProperties setObject:[[NSString alloc] initWithString:currentValue] forKey:elementName];
}

@end
