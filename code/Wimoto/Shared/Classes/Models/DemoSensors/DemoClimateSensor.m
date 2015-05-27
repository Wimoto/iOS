//
//  DemoClimateSensor.m
//  Wimoto
//
//  Created by MC700 on 30.10.14.
//
//

#import "DemoClimateSensor.h"

@interface DemoClimateSensor ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) NSTimeInterval temperatureAlarmTimeshot;
@property (nonatomic) NSTimeInterval humidityAlarmTimeshot;
@property (nonatomic) NSTimeInterval lightAlarmTimeshot;

- (void)sensorUpdate;

@end

@implementation DemoClimateSensor

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"Demo Climate";
        self.uniqueIdentifier = BLE_CLIMATE_DEMO_MODEL;
        _temperature = 22.0;
        _humidity = 50.0;
        _light = 60.0;
        
        self.temperatureAlarmLow = 15.0;
        self.temperatureAlarmHigh = 28.0;
        
        self.humidityAlarmLow = 37.0;
        self.humidityAlarmHigh = 69.0;
        
        self.lightAlarmLow = 49.0;
        self.lightAlarmHigh = 72.0;
    }
    return self;
}

- (void)setEntity:(SensorEntity *)entity {
    _temperature = 22.0;
    _humidity = 50.0;
    _light = 60.0;
    
    self.temperatureAlarmLow = 15.0;
    self.temperatureAlarmHigh = 28.0;
    
    self.humidityAlarmLow = 37.0;
    self.humidityAlarmHigh = 69.0;
    
    self.lightAlarmLow = 49.0;
    self.lightAlarmHigh = 72.0;

    [super setEntity:entity];
}

- (PeripheralType)type {
    return kPeripheralTypeClimateDemo;
}

- (NSString *)codename {
    return @"Climate";
}

- (void)sensorUpdate {
    int temperatureStep = arc4random()%4 + 1 - 4/2;
    if ((_temperature + temperatureStep) < (-5)) {
        self.temperature+=2.0;
    }
    else if ((_temperature + temperatureStep) > 50) {
        self.temperature-=2.0;
    }
    else {
        self.temperature+=temperatureStep;
    }
    
    int humidityStep = arc4random()%4 + 1 - 4/2;
    if ((_humidity + humidityStep) < (0)) {
        self.humidity+=2.0;
    }
    else if ((_humidity + humidityStep) > 100) {
        self.humidity-=2.0;
    }
    else {
        self.humidity+=humidityStep;
    }
    
    int lightStep = arc4random()%4 + 1 - 4/2;
    if ((_light + lightStep) < 0) {
        self.light+=2.0;
    }
    else if ((_light + lightStep) > 200) {
        self.light-=2.0;
    }
    else {
        self.light+=lightStep;
    }
    
    if ((self.temperatureAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_temperatureAlarmTimeshot+30))) {
        _temperatureAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
        NSString *alarmType = nil;
        if (self.temperature > self.temperatureAlarmHigh) {
            alarmType = @"high value";
        }
        else if (self.temperature < self.temperatureAlarmLow) {
            alarmType = @"low value";
        }
        if (alarmType) {
            [super showAlarmNotification:[NSString stringWithFormat:@"%@ temperature %@", self.name, alarmType] forUuid:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET];
        }
    }
    if ((self.humidityAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_humidityAlarmTimeshot+30))) {
        _humidityAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
        NSString *alarmType = nil;
        if (self.humidity > self.humidityAlarmHigh) {
            alarmType = @"high value";
        }
        else if (self.humidity < self.humidityAlarmLow) {
            alarmType = @"low value";
        }
        if (alarmType) {
            [super showAlarmNotification:[NSString stringWithFormat:@"%@ humidity %@", self.name, alarmType] forUuid:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET];
        }
    }
    if ((self.lightAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_lightAlarmTimeshot+30))) {
        _lightAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
        NSString *alarmType = nil;
        if (self.light > self.lightAlarmHigh) {
            alarmType = @"high value";
        }
        else if (self.light < self.lightAlarmLow) {
            alarmType = @"low value";
        }
        if (alarmType) {
            [super showAlarmNotification:[NSString stringWithFormat:@"%@ light %@", self.name, alarmType] forUuid:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET];
        }
    }
    [self.entity saveNewValueWithType:kValueTypeTemperature value:_temperature];
    [self.entity saveNewValueWithType:kValueTypeHumidity value:_humidity];
    [self.entity saveNewValueWithType:kValueTypeLight value:_light];
}

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString {
    if ([UUIDString isEqual:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET]) {
        self.temperatureAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    } else if ([UUIDString isEqual:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET]) {
        self.lightAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    } else if ([UUIDString isEqual:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET]) {
        self.humidityAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    }
}

@end
