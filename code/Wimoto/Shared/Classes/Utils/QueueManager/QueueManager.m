//
//  QueueManager.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.07.14.
//
//

#import "QueueManager.h"

@interface QueueManager ()

+ (QueueManager *)sharedManager;

@property (nonatomic, strong) dispatch_queue_t managerQueue;

@end

@implementation QueueManager

static QueueManager *queueManager = nil;

+ (QueueManager *)sharedManager {
	if (!queueManager) {
		queueManager = [[QueueManager alloc] init];
	}
	return queueManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.managerQueue = dispatch_queue_create("com.wimoto.databaseQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (dispatch_queue_t)databaseQueue {
    return [[QueueManager sharedManager] managerQueue];
}

@end
