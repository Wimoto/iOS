//
//  SPURLConnection.h
//  Softmaker
//
//  Created by MC700 on 10/25/12.
//
//

#import "WPRequest.h"
#import "WPResponse.h"

@protocol WPURLConnectionDelegate;
@protocol WPResponseReceiver;

@interface WPURLConnection : NSObject

@property (nonatomic, assign) id<WPURLConnectionDelegate> opConnectionDelegate;
@property (nonatomic, assign) id<WPResponseReceiver> opResponseReceiver;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, strong) WPRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *networkData;

- (id)initWithRequest:(WPRequest*)request responseReceiver:(id<WPResponseReceiver>)spResponseReceiver andDelegate:(id<WPURLConnectionDelegate>)spConnectionDelegate;
- (void)cancel;

@end

@protocol WPURLConnectionDelegate <NSObject>
- (void)didFinishConnection:(WPURLConnection*)connection;
@end

@protocol WPResponseReceiver <NSObject>
- (void)processResponse:(WPResponse*)response;
@optional
- (void)processError:(NSError*)error;
- (void)downloadProgress:(float)progress request:(WPRequest *)request;
@end