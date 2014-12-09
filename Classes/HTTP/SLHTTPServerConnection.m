//
//  HTTPServerConnection.m
//  LightSwitchStatus
//
//  Created by Scott Langendyk on 2014-01-22.
//  Copyright (c) 2014 Scott Langendyk. All rights reserved.
//

#import "SLHTTPServerConnection.h"

#define HTTP_REQUEST_STARTLINE  10
#define HTTP_REQUEST_HEADER     11
#define HTTP_REQUEST_BODY       12
#define HTTP_REQUEST_CHUNK_SIZE 13
#define HTTP_REQUEST_CHUNK_BODY 14
#define HTTP_RESPONSE           15

@implementation SLHTTPServerConnection

@synthesize delegate;

#pragma mark Initialization

- (id)initWithSocket:(GCDAsyncSocket *)aSocket andDelegate:(id <SLHTTPServerConnectionDelegate>)aDelegate;
{
    self = [super init];

    if (self) {
        socket = aSocket;
        delegate = aDelegate;
    }

    return self;
}

#pragma mark Setup/Control

- (void)parseRequest
{
    [socket setDelegate:self];

    [self readStartLine];
}

- (void)sendResponse:(NSData *)aResponse;
{
    [socket writeData:aResponse withTimeout:-1 tag:HTTP_RESPONSE];
}

- (void)close
{
    [socket setDelegate:nil];

    if ([socket isConnected]) {
        [socket disconnect];
        [self notifyDelegateClosed];
    }
}

#pragma mark GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    lastData = data;

    switch (tag) {
        case HTTP_REQUEST_STARTLINE:
            [self parseStartLine];
            break;

        case HTTP_REQUEST_HEADER:
            [self parseHeader];
            break;

        case HTTP_REQUEST_BODY:
            [self parseBody];
            break;

        case HTTP_REQUEST_CHUNK_SIZE:
            [self parseChunkSize];
            break;

        case HTTP_REQUEST_CHUNK_BODY:
            [self parseChunkBody];
            break;

        default:
            [self close];
            break;
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (sock == socket && tag == HTTP_RESPONSE) {
        [self close];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock == socket) {
        [socket setDelegate:nil];

        [self notifyDelegateClosed];
    }
}

#pragma mark Helpers

- (void)readStartLine
{
    [socket readDataToData:[GCDAsyncSocket CRData] withTimeout:30 maxLength:8190 tag:HTTP_REQUEST_STARTLINE];
}

- (void)parseStartLine
{
    // In the interest of robustness, servers SHOULD ignore any empty line(s) received where a Request-Line is
    // expected. In other words, if the server is reading the protocol stream at the beginning of a message and
    // receives a CRLF first, it should ignore the CRLF.
    //
    // RFC 2616 [4.1]

    if ([lastData isEqualToData:[GCDAsyncSocket CRLFData]]) {
        [self readStartLine];

        return;
    }

    // Remove the CRLF
    lastData = [lastData subdataWithRange:NSMakeRange(0, [lastData length] - 2)];

    // Parse the start line
    NSString *startLine = [[NSString alloc] initWithData:lastData encoding:NSASCIIStringEncoding];
    NSArray *parts = [startLine componentsSeparatedByString:@" "];

    // Validate the start line
    if ([parts count] != 3 && ![[parts objectAtIndex:2] isEqualToString:@"HTTP/1.1"]) {
        [self close];

        return;
    }

    method = [parts objectAtIndex:0];
    URI = [parts objectAtIndex:1];

    [self readHeader];
}

- (void)readHeader
{
    [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:30 maxLength:8190 tag:HTTP_REQUEST_HEADER];
}

- (void)parseHeader
{
    if (!headerData) {
        headerData = [[NSMutableData alloc] init];
    }

    // Keep reading headers until we get a single CRLF
    if ([lastData isEqualToData:[GCDAsyncSocket CRLFData]]) {
        headers = [SLHTTPHeaders headersFromData:[NSData dataWithData:headerData]];

        [self readBody];

        return;
    }

    [headerData appendData:lastData];

    [self readHeader];
}

- (void)readBody
{
    // RFC 2616 [4.3] Message Body
    //
    // The message-body (if any) of an HTTP message is used to carry the entity-body associated with the request or response.
    // The message-body differs from the entity-body only when a transfer-coding has been applied, as indicated by the Transfer-Encoding
    // header field (section 14.41).
    //
    // message-body = entity-body
    //              | <entity-body encoded as per Transfer-Encoding>
    //
    // Transfer-Encoding MUST be used to indicate any transfer-codings applied by an application to ensure safe and proper transfer of the
    // message. Transfer-Encoding is a property of the message, not of the entity, and thus MAY be added or removed by any application along
    // the request/response chain. (However, section 3.6 places restrictions on when certain transfer-codings may be used.)
    //
    // The rules for when a message-body is allowed in a message differ for requests and responses.
    //
    // The presence of a message-body in a request is signaled by the inclusion of a Content-Length or Transfer-Encoding header field in the
    // request's message-headers. A message-body MUST NOT be included in a request if the specification of the request method (section 5.1.1)
    // does not allow sending an entity-body in requests. A server SHOULD read and forward a message-body on any request; if the request method
    // does not include defined semantics for an entity-body, then the message-body SHOULD be ignored when handling the request.
    //
    // For response messages, whether or not a message-body is included with a message is dependent on both the request method and the response
    // status code (section 6.1.1). All responses to the HEAD request method MUST NOT include a message-body, even though the presence of
    // entity- header fields might lead one to believe they do. All 1xx (informational), 204 (no content), and 304 (not modified) responses MUST NOT
    // include a message-body. All other responses do include a message-body, although it MAY be of zero length.

    if (!body) {
        body = [[NSMutableData alloc] init];
    }

    // RFC 2616 [4.4] Message Length
    //
    // The transfer-length of a message is the length of the message-body as it appears in the message; that is,
    // after any transfer-codings have been applied. When a message-body is included with a message, the transfer-length
    // of that body is determined by one of the following (in order of precedence):
    //
    // 1.Any response message which "MUST NOT" include a message-body (such as the 1xx, 204, and 304 responses and any
    // response to a HEAD request) is always terminated by the first empty line after the header fields, regardless of the
    // entity-header fields present in the message.
    //
    // 2.If a Transfer-Encoding header field (section 14.41) is present and has any value other than "identity", then the
    // transfer-length is defined by use of the "chunked" transfer-coding (section 3.6), unless the message is terminated by
    // closing the connection.
    //
    // 3.If a Content-Length header field (section 14.13) is present, its decimal value in OCTETs represents both the
    // entity-length and the transfer-length. The Content-Length header field MUST NOT be sent if these two lengths are
    // different (i.e., if a Transfer-Encoding header field is present). If a message is received with both a Transfer-Encoding
    // header field and a Content-Length header field, the latter MUST be ignored
    //
    // 4.If the message uses the media type "multipart/byteranges", and the transfer-length is not otherwise specified, then this
    // self- delimiting media type defines the transfer-length. This media type MUST NOT be used unless the sender knows that the
    // recipient can parse it; the presence in a request of a Range header with multiple byte- range specifiers from a 1.1 client
    // implies that the client can parse multipart/byteranges responses.
    //
    // A range header might be forwarded by a 1.0 proxy that does not
    // understand multipart/byteranges; in this case the server MUST
    // delimit the message using methods defined in items 1,3 or 5 of
    // this section.
    //
    // 5.By the server closing the connection. (Closing the connection cannot be used to indicate the end of a request body, since
    // that would leave no possibility for the server to send back a response.)
    //
    // For compatibility with HTTP/1.0 applications, HTTP/1.1 requests containing a message-body MUST include a valid Content-Length
    // header field unless the server is known to be HTTP/1.1 compliant. If a request contains a message-body and a Content-Length is
    // not given, the server SHOULD respond with 400 (bad request) if it cannot determine the length of the message, or with
    // 411 (length required) if it wishes to insist on receiving a valid Content-Length.
    //
    // All HTTP/1.1 applications that receive entities MUST accept the "chunked" transfer-coding (section 3.6), thus allowing this
    // mechanism to be used for messages when the message length cannot be determined in advance. Messages MUST NOT include both a
    // Content-Length header field and a non-identity transfer-coding. If the message does include a non- identity transfer-coding,
    // the Content-Length MUST be ignored.
    //
    // When a Content-Length is given in a message where a message-body is allowed, its field value MUST exactly match the number of
    // OCTETs in the message-body. HTTP/1.1 user agents MUST notify the user when an invalid length is received and detected.

    NSArray *transferEncoding = [headers transferEncoding];

    if ([transferEncoding containsObject:@"chunked"]) {
        [self readChunkSize];

        return;
    }

    NSString *contentLength = [headers valueForHeader:@"Content-Length"];

    if (contentLength) {
        [socket readDataToLength:(NSUInteger)[contentLength integerValue] withTimeout:-1 tag:HTTP_REQUEST_BODY];

        return;
    }

    [self createRequest];
}

- (void)parseBody
{
    body = [NSMutableData dataWithData:lastData];

    [self createRequest];
}

- (void)readChunkSize
{
    [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:HTTP_REQUEST_CHUNK_SIZE];
}

- (void)parseChunkSize
{
    // Remove the CRLF
    lastData = [lastData subdataWithRange:NSMakeRange(0, [lastData length] - 2)];

    NSString *size = [[NSString alloc] initWithData:lastData encoding:NSASCIIStringEncoding];

    NSRange range = [size rangeOfString:@";"];

    if (range.location != NSNotFound) {
        size = [size substringToIndex:range.location];
    }

    unsigned int sizeVal;
    NSScanner* scanner = [NSScanner scannerWithString:size];
    [scanner scanHexInt:&sizeVal];

    // Last chunk is defined as having 0 size
    if (sizeVal == 0) {
        [self createRequest];

        return;
    }

    [socket readDataToLength:sizeVal withTimeout:-1 tag:HTTP_REQUEST_CHUNK_BODY];
}

- (void)parseChunkBody
{
    [body appendData:lastData];

    [self readChunkSize];
}

- (void)createRequest
{
    request = [[SLHTTPRequest alloc] initWithMethod:method URI:URI headers:headers body:[NSData dataWithData:body]];

    if (delegate && [delegate respondsToSelector:@selector(connection:didParseRequest:)]) {
        [delegate connection:self didParseRequest:request];
    } else {
        [self sendResponse:[@"HTTP/1.1 500 Internal Server Error\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    }
}

- (void)notifyDelegateClosed
{
    if (delegate && [delegate respondsToSelector:@selector(connectionDidClose:)]) {
        [delegate connectionDidClose:self];
    }
}

@end
