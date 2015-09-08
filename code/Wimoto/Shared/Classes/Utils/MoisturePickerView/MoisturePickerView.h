//
//  MoisturePickerView.h
//  Wimoto
//
//  Created by Ievgen on 9/7/15.
//
//

typedef void(^MoistureCancelBlock)();
typedef void(^MoistureSaveBlock)(float value);

@interface MoisturePickerView : UIView

+ (id)showWithValue:(float)value lowCalibrationValue:(NSNumber *)lowCalibrationValue highCalibrationValue:(NSNumber *)highCalibrationValue save:(MoistureSaveBlock)saveBlock cancel:(MoistureCancelBlock)cancelBlock;

@end
