//
//  GrowSensorEntity.h
//  Wimoto
//
//  Created by Ievgen on 9/2/15.
//
//

#import "SensorEntity.h"

@interface GrowSensorEntity : SensorEntity

@property (copy) NSNumber   *lowHumidityCalibration;
@property (copy) NSNumber   *highHumidityCalibration;

@end
