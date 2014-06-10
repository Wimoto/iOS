//
//  SPURLConnection.m
//  Softmaker
//
//  Created by MC700 on 10/25/12.
//
//

#import "WPURLConnection.h"

@interface WPURLConnection ()

@property (nonatomic, retain) NSURLRequest *formatedRequest;

@end

@implementation WPURLConnection

- (id)initWithRequest:(WPRequest*)request responseReceiver:(id<WPResponseReceiver>)spResponseReceiver andDelegate:(id<WPURLConnectionDelegate>)spConnectionDelegate {
    self = [super init];
    if (self) {
        self.networkData = [NSMutableData data];
        self.request = request;
        self.opConnectionDelegate = spConnectionDelegate;
        self.opResponseReceiver = spResponseReceiver;
        self.formatedRequest = [_request formRequest];
        self.connection = [[NSURLConnection alloc] initWithRequest:_formatedRequest delegate:self startImmediately:NO];
        [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [_connection start];
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_networkData appendData:data];
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error {
    if ([_opResponseReceiver respondsToSelector:@selector(processError:)]) {
        [_opResponseReceiver processError:error];
    }
    self.networkData = nil;
    self.connection = nil;
    [_opConnectionDelegate didFinishConnection:self];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.statusCode = [httpResponse statusCode];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection {
    if ([_opResponseReceiver respondsToSelector:@selector(processResponse:)]) {
        WPResponse *response = [WPResponse responseWithData:_networkData andRequest:_request code:_statusCode];
        [_opResponseReceiver processResponse:response];
        self.networkData = nil;
        self.connection = nil;
        [_opConnectionDelegate didFinishConnection:self];
    }
}

- (void)cancel {
    [_connection cancel];
    self.networkData = nil;
	self.connection = nil;
    [_opConnectionDelegate didFinishConnection:self];
    self.opConnectionDelegate = nil;
}

@end
