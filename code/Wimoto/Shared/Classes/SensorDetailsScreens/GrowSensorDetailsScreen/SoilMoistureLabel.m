//
//  SoilMoistureLabel.m
//  Wimoto
//
//  Created by Ievgen on 9/7/15.
//
//

#import "SoilMoistureLabel.h"

@implementation SoilMoistureLabel

- (void)setSoilMoisture:(float)moisture withLowCalibrationValue:(NSNumber *)lowCalibrationValue andHighCalibrationValue:(NSNumber *)highCalibrationValue {
    if ((lowCalibrationValue) && (highCalibrationValue)) {
        float lowCalibration = [lowCalibrationValue floatValue];
        float highCalibration = [highCalibrationValue floatValue];

        float calibrationStep = (highCalibration - lowCalibration)/4;
        if ((lowCalibration + calibrationStep * 1) > moisture) {
            self.text = @"Very wet";
        } else if ((lowCalibration + calibrationStep * 2) > moisture) {
            self.text = @"Wet";
        } else if ((lowCalibration + calibrationStep * 3) > moisture) {
            self.text = @"Normal";
        } else if ((lowCalibration + calibrationStep * 4) > moisture) {
            self.text = @"Dry";
        } else if (highCalibration < moisture) {
            self.text = @"Very dry";
        } else {
            self.text = @"Very dry";
        }
    }
//    else {
//        self.text = [NSString stringWithFormat:@"%.1f", moisture];
//    }
}

@end
