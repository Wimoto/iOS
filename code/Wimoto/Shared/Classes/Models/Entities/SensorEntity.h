//
//  SensorEntity.h
//  Wimoto
//
//  Created by MC700 on 12/16/13.
//
//

#import <Couchbaselite/Couchbaselite.h>

@interface SensorEntity : CBLModel

@property (copy) NSString *sensorId;

@end
