//
//  SPNetworkConnection.h
//  Softmaker
//
//  Created by MC700 on 10/24/12.
//
//

#import "WPURLConnection.h"

@interface WPNetworkDispatcher : NSObject<WPURLConnectionDelegate> 

@property (nonatomic, strong) NSMutableArray *dispatcherConnections;

+ (void)performNetworkRequest:(WPRequest*)_request withResponseReceiver:(id<WPResponseReceiver>)_responseReceiver;
+ (void)invalidateRequestForReceiver:(id<WPResponseReceiver>)_responseReceiver;
+ (void)invalidateRequest:(WPRequest *)_request forReceiver:(id<WPResponseReceiver>)_responseReceiver;
+ (void)invalidateRequestWithType:(WPRequestType)type;

@end
