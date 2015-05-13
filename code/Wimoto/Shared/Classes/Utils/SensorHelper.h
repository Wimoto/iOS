//
//  SensorHelper.h
//  Wimoto
//
//  Created by Danny Kokarev on 06.02.14.
//
//

#import <Foundation/Foundation.h>

@interface SensorHelper : NSObject

+ (float)getHumidityValue:(uint16_t)u16sRH;
+ (float)getTemperatureValue:(uint16_t)u16sT;

+ (float)fahrenheitFromCelcius:(float)celsius;
+ (float)celsiusFromFahrenheit:(float)fahrenheit;

@end
