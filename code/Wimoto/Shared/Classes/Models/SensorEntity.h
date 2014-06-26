//
//  SensorEntity.h
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import <Couchbaselite/Couchbaselite.h>
#import "CBPeripheral+Util.h"

@interface SensorEntity : CBLModel

@property (copy) NSString   *name;
@property (copy) NSString   *systemId;
@property (copy) NSDate     *lastActivityAt;
@property (copy) NSNumber   *type;

@end
