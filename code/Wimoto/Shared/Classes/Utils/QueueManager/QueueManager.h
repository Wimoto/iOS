//
//  QueueManager.h
//  Wimoto
//
//  Created by Danny Kokarev on 03.07.14.
//
//

#import <Foundation/Foundation.h>

@interface QueueManager : NSObject

+ (dispatch_queue_t)databaseQueue;

@end
