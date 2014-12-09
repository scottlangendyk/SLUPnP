//
//  UPnPDevice.m
//  CocoaUPnP
//
//  Created by Scott Langendyk on 2014-03-23.
//

#import "SLUPnPDevice.h"
#import "SLUPnPDevices.h"
#import "SLUPnPService.h"
#import "SLUPnPServices.h"

@implementation SLUPnPDevice

@synthesize deviceType = _deviceType;
@synthesize friendlyName = _friendlyName;
@synthesize childDevices = _childDevices;
@synthesize UDN = _UDN;
@synthesize services = _services;
@synthesize descriptionURL = _descriptionURL;
@synthesize parentDevice = _parentDevice;

#pragma mark - Initialization

- (id)initWithDescriptionURL:(NSURL *)descriptionURL
{
    self = [super init];

    if (self) {
        _descriptionURL = descriptionURL;
    }

    return self;
}

- (id)initWithParentDevice:(SLUPnPDevice *)parentDevice
{
    _parentDevice = parentDevice;
    
    return [self initWithDescriptionURL:[parentDevice descriptionURL]];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _deviceType = [aDecoder decodeObjectForKey:@"deviceType"];
        _friendlyName = [aDecoder decodeObjectForKey:@"friendlyName"];
        _childDevices = [aDecoder decodeObjectForKey:@"childDevices"];
        _UDN = [aDecoder decodeObjectForKey:@"UDN"];
        _services = [aDecoder decodeObjectForKey:@"services"];
        _descriptionURL = [aDecoder decodeObjectForKey:@"descriptionURL"];
        _parentDevice = [aDecoder decodeObjectForKey:@"parentDevice"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_deviceType forKey:@"deviceType"];
    [aCoder encodeObject:_friendlyName forKey:@"friendlyName"];
    [aCoder encodeObject:_childDevices forKey:@"childDevices"];
    [aCoder encodeObject:_UDN forKey:@"UDN"];
    [aCoder encodeObject:_services forKey:@"services"];
    [aCoder encodeObject:_descriptionURL forKey:@"descriptionURL"];
    [aCoder encodeObject:_parentDevice forKey:@"parentDevice"];
}

# pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _currentValue = [[NSMutableString alloc] init];
    
    if ([elementName isEqualToString:@"deviceList"]) {
        _devicesSet = [[NSMutableSet alloc] init];
    } else if ([elementName isEqualToString:@"serviceList"]) {
        _servicesSet = [[NSMutableSet alloc] init];
    } else if ([elementName isEqualToString:@"device"] && _devicesSet) {
        SLUPnPDevice *device = [[SLUPnPDevice alloc] initWithParentDevice:self];
        [_devicesSet addObject:device];
        [parser setDelegate:device];
    } else if ([elementName isEqualToString:@"service"] && _servicesSet) {
        SLUPnPService *service = [[SLUPnPService alloc] initWithDevice:self];
        [_servicesSet addObject:service];
        [parser setDelegate:service];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *value = [[NSString alloc] initWithString:_currentValue];
    
    if ([elementName isEqualToString:@"deviceList"]) {
        _childDevices = [[SLUPnPDevices alloc] initWithDevicesSet:_devicesSet];
        _devicesSet = nil;
    } else if ([elementName isEqualToString:@"serviceList"]) {
        _services = [[SLUPnPServices alloc] initWithServicesSet:_servicesSet];
        _servicesSet = nil;
    } else if ([elementName isEqualToString:@"device"]) {
        [parser setDelegate:_parentDevice];
    } else if ([elementName isEqualToString:@"deviceType"]) {
        _deviceType = value;
    } else if ([elementName isEqualToString:@"friendlyName"]) {
        _friendlyName = value;
    } else if ([elementName isEqualToString:@"UDN"]) {
        _UDN = value;
    }
}

+ (SLUPnPDevice *)deviceInDevice:(SLUPnPDevice *)device withUDN:(NSString *)UDN
{
    if ([[device UDN] isEqualToString:UDN]) {
        return device;
    }
    
    for (SLUPnPDevice *childDevice in [[device childDevices] allDevices]) {
        SLUPnPDevice *foundDevice = [SLUPnPDevice deviceInDevice:childDevice withUDN:UDN];
        
        if (foundDevice) {
            return foundDevice;
        }
    }
    
    return nil;
}

@end
