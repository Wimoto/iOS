//
//  SensorManager.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "SensorManager.h"

@implementation SensorManager

static SensorManager *sensorManager = nil;

+ (SensorManager*)sensorManager {
	if (!sensorManager) {
		sensorManager = [[SensorManager alloc] init];
    }
    return sensorManager;
}

+ (NSArray*)getSensors {
    return [[SensorManager sensorManager] getSensors];
}

- (NSArray*)getSensors {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:@"Sensors.plist"];
    
	NSArray *sensorDescriptions = [[NSArray alloc] initWithContentsOfFile:plistPath];
	NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[sensorDescriptions count]];
    for (NSDictionary *dictionary in sensorDescriptions) {
        [mutableArray addObject:[[Sensor alloc] initWithDictionary:dictionary]];
    }
    return mutableArray;
}

+ (void)addSensor:(Sensor*)sensor {
    [[SensorManager sensorManager] addSensor:sensor];
}

- (void)addSensor:(Sensor*)sensor {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:@"Sensors.plist"];
    
	NSMutableArray *sensorDescriptions = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if (!sensorDescriptions) {
        sensorDescriptions = [NSMutableArray arrayWithCapacity:0];
    }
    
    [sensorDescriptions addObject:[sensor dictionaryRepresentation]];
    
    [sensorDescriptions writeToFile:plistPath atomically:YES];
}

@end
