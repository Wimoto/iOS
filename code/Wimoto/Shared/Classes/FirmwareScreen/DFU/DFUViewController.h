//
//  DFUViewController.h
//  nRF Toolbox
//
//  Created by Aleksander Nowakowski on 10/01/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DFUOperations.h"
#import "AppViewController.h"

#import "Firmware.h"
#import "Sensor.h"

@interface DFUViewController : AppViewController <DFUOperationsDelegate>

- (id)initWithSensor:(Sensor *)sensor andFirmware:(Firmware *)firmware;

@end
