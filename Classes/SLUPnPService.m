//
//  UPnPService.m
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-03-23.
//

#import "SLUPnPService.h"
#import "SLUPnPDevice.h"

@implementation SLUPnPService

@synthesize serviceType;
@synthesize serviceId;
@synthesize SCPDURL;
@synthesize controlURL;
@synthesize eventSubURL;
@synthesize device;

- (id)initWithDevice:(SLUPnPDevice *)aDevice
{
    self = [super init];

    if (self) {
        device = aDevice;
    }

    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        serviceType = [aDecoder decodeObjectForKey:@"serviceType"];
        serviceId = [aDecoder decodeObjectForKey:@"serviceId"];
        SCPDURL = [aDecoder decodeObjectForKey:@"SCPDURL"];
        controlURL = [aDecoder decodeObjectForKey:@"controlURL"];
        eventSubURL = [aDecoder decodeObjectForKey:@"eventSubURL"];
        device = [aDecoder decodeObjectForKey:@"device"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:serviceType forKey:@"serviceType"];
    [aCoder encodeObject:serviceId forKey:@"serviceId"];
    [aCoder encodeObject:SCPDURL forKey:@"SCPDURL"];
    [aCoder encodeObject:controlURL forKey:@"controlURL"];
    [aCoder encodeObject:eventSubURL forKey:@"eventSubURL"];
    [aCoder encodeObject:device forKey:@"device"];
}

- (NSURLRequest *)invokeAction:(NSString *)actionName
{
    return [self invokeAction:actionName withParameters:nil];
}

- (NSURLRequest *)invokeAction:(NSString *)actionName withParameters:(NSDictionary *)actionParameters
{
    NSMutableString *body = [[NSMutableString alloc] init];

    [body appendString:@"<?xml version=\"1.0\"?>\r\n"];
    [body appendString:@"<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n"];
    [body appendString:@"<s:Body>\r\n"];
    [body appendString:[NSString stringWithFormat:@"<u:%@ xmlns:u=\"%@\">\r\n", actionName, serviceType]];

    for (NSString *parameter in actionParameters) {
        [body appendString:[NSString stringWithFormat:@"<%@>%@</%@>\r\n", parameter, [actionParameters objectForKey:parameter], parameter]];
    }

    [body appendString:[NSString stringWithFormat:@"</u:%@>\r\n", actionName]];
    [body appendString:@"</s:Body>\r\n"];
    [body appendString:@"</s:Envelope>\r\n\r\n"];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    unsigned long bodyLength = (unsigned long)[bodyData length];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:controlURL];

    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%ld", bodyLength] forHTTPHeaderField:@"CONTENT-LENGTH"];
    [request setValue:@"text/xml; charset=\"utf-8\"" forHTTPHeaderField:@"CONTENT-TYPE"];
    [request setValue:[NSString stringWithFormat:@"\"%@#%@\"", serviceType, actionName] forHTTPHeaderField:@"SOAPACTION"];
    [request setHTTPBody:bodyData];

    return request;
}

- (NSURLRequest *)subscribeWithCallback:(NSURL *)aCallback
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:eventSubURL];

    [request setHTTPMethod:@"SUBSCRIBE"];
    [request setValue:@"upnp:event" forHTTPHeaderField:@"NT"];
    [request setValue:[NSString stringWithFormat:@"<%@>", aCallback] forHTTPHeaderField:@"CALLBACK"];
    [request setValue:[self host] forHTTPHeaderField:@"HOST"];

    return request;
}

- (NSURLRequest *)renewWithId:(NSString *)aSubscriptionId
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:eventSubURL];

    [request setHTTPMethod:@"SUBSCRIBE"];
    [request setValue:aSubscriptionId forHTTPHeaderField:@"SID"];
    [request setValue:[self host] forHTTPHeaderField:@"HOST"];

    return request;
}

- (NSURLRequest *)unsubscribeWithId:(NSString *)aSubscriptionId
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:eventSubURL];

    [request setHTTPMethod:@"UNSUBSCRIBE"];
    [request setValue:aSubscriptionId forHTTPHeaderField:@"SID"];
    [request setValue:[self host] forHTTPHeaderField:@"HOST"];

    return request;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentValue = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *value = [[NSString alloc] initWithString:currentValue];

    if ([elementName isEqualToString:@"serviceType"]) {
        serviceType = value;
    } else if ([elementName isEqualToString:@"serviceId"]) {
        serviceId = value;
    } else if ([elementName isEqualToString:@"SCPDURL"]) {
        SCPDURL = [NSURL URLWithString:value relativeToURL:[self baseURL]];
    } else if ([elementName isEqualToString:@"controlURL"]) {
        controlURL = [NSURL URLWithString:value relativeToURL:[self baseURL]];
    } else if ([elementName isEqualToString:@"eventSubURL"]) {
        eventSubURL = [NSURL URLWithString:value relativeToURL:[self baseURL]];
    } else if ([elementName isEqualToString:@"service"]) {
        [parser setDelegate:device];
    }
}

- (NSString *)host
{
    return [NSString stringWithFormat:@"%@:%@", [eventSubURL host], [eventSubURL port]];
}

- (NSURL *)baseURL
{
    return [device descriptionURL];
}

@end
