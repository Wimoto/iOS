//
//  FirmwareUploadViewController.h
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "AppViewController.h"
#import "DFUController.h"
#import "Firmware.h"
#import "Sensor.h"

@interface FirmwareUploadViewController : AppViewController <DFUControllerDelegate>

- (id)initWithSensor:(Sensor *)sensor andFirmware:(Firmware *)firmware;

@end
