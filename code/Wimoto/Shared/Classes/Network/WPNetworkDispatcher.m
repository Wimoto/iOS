//
//  SPNetworkConnection.m
//  Softmaker
//
//  Created by MC700 on 10/24/12.
//
//

#import "WPNetworkDispatcher.h"
#import "WPRequest.h"

@interface WPNetworkDispatcher (PrivateMethods)

- (void)performRequest:(WPRequest*)_request withDelegate:(id<WPURLConnectionDelegate>)_delegate;

@end

@implementation WPNetworkDispatcher

static WPNetworkDispatcher *networkDispatcher = nil;

@synthesize dispatcherConnections;

+ (WPNetworkDispatcher*)networkDispatcher {
	if (!networkDispatcher) {
		networkDispatcher = [[WPNetworkDispatcher alloc] init];		
	}
	return networkDispatcher;
}

- (id)init {
    self = [super init];
    if (self) {
        self.dispatcherConnections = [NSMutableArray array];
    }
    return self;
}

+ (void)performNetworkRequest:(WPRequest*)_request withResponseReceiver:(id<WPResponseReceiver>)_responseReceiver {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[[WPNetworkDispatcher networkDispatcher] performRequest:_request withResponseReceiver:_responseReceiver];
}

- (void)performRequest:(WPRequest*)_request withResponseReceiver:(id<WPResponseReceiver>)_responseReceiver {
    WPURLConnection *connection = [[WPURLConnection alloc] initWithRequest:_request responseReceiver:_responseReceiver andDelegate:self];
    [dispatcherConnections addObject:connection];
}

- (void)didFinishConnection:(WPURLConnection*)connection {
    connection.opResponseReceiver = nil;
    [dispatcherConnections removeObject:connection];
    if ([dispatcherConnections count] == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

+ (void)invalidateRequestForReceiver:(id<WPResponseReceiver>)_responseReceiver {
    NSMutableArray *connectionsForCancellation = [NSMutableArray array];
    NSArray *connections = [[WPNetworkDispatcher networkDispatcher] dispatcherConnections];
    for (WPURLConnection *connection in connections) {
        if ([connection.opResponseReceiver isEqual:_responseReceiver]) {
            [connectionsForCancellation addObject:connection];
            break;
        }
    }
    for (WPURLConnection *connection in connectionsForCancellation) {
        [connection cancel];
    }
}

+ (void)invalidateRequest:(WPRequest *)_request forReceiver:(id<WPResponseReceiver>)_responseReceiver
{
    NSMutableArray *connectionsForCancellation = [NSMutableArray array];
    NSArray *connections = [[WPNetworkDispatcher networkDispatcher] dispatcherConnections];
    for (WPURLConnection *connection in connections) {
        if ([connection.opResponseReceiver isEqual:_responseReceiver] && (connection.request.requestType == _request.requestType)) {
            [connectionsForCancellation addObject:connection];
            break;
        }
    }
    for (WPURLConnection *connection in connectionsForCancellation) {
        [connection cancel];
    }
}

+ (void)invalidateRequestWithType:(WPRequestType)type
{
    NSArray *connections = [[WPNetworkDispatcher networkDispatcher] dispatcherConnections];
    for (WPURLConnection *connection in connections) {
        if (connection.request.requestType == type) {
            [connection cancel];
            break;
        }
    }
}

@end
