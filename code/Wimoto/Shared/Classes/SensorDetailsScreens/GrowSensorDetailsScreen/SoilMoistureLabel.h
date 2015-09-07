//
//  SoilMoistureLabel.h
//  Wimoto
//
//  Created by Ievgen on 9/7/15.
//
//

#import <Foundation/Foundation.h>

@interface SoilMoistureLabel : UILabel

- (void)setSoilMoisture:(float)moisture withLowCalibrationValue:(NSNumber *)lowCalibrationValue andHighCalibrationValue:(NSNumber *)highCalibrationValue;

@end
