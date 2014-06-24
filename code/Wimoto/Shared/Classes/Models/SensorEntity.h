//
//  SensorEntity.h
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import <Couchbaselite/Couchbaselite.h>

@interface SensorEntity : CBLModel

@property (copy) NSString *name;
@property (copy) NSString *systemId;
@property (copy) NSDate *lastUpdateDate;

@end
