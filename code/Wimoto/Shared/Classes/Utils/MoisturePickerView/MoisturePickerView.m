//
//  MoisturePickerView.m
//  Wimoto
//
//  Created by Ievgen on 9/7/15.
//
//

#import "MoisturePickerView.h"

@interface MoisturePickerView ()

@property (nonatomic) NSNumber *lowCalibrationValue;
@property (nonatomic) NSNumber *highCalibrationValue;

@property (nonatomic, copy) MoistureSaveBlock saveBlock;
@property (nonatomic, copy) MoistureCancelBlock cancelBlock;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIToolbar *pickerViewContainer;

@property (nonatomic, strong) NSArray *pickerValues;

- (void)hide;
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

@implementation MoisturePickerView

+ (id)showWithValue:(float)value lowCalibrationValue:(NSNumber *)lowCalibrationValue highCalibrationValue:(NSNumber *)highCalibrationValue save:(MoistureSaveBlock)saveBlock cancel:(MoistureCancelBlock)cancelBlock {
    MoisturePickerView *pickerView = [[MoisturePickerView alloc] init];
    [pickerView showWithValue:value lowCalibrationValue:lowCalibrationValue highCalibrationValue:highCalibrationValue save:saveBlock cancel:cancelBlock];
    return pickerView;
}

- (void)showWithValue:(float)value lowCalibrationValue:(NSNumber *)lowCalibrationValue highCalibrationValue:(NSNumber *)highCalibrationValue save:(MoistureSaveBlock)saveBlock cancel:(MoistureCancelBlock)cancelBlock {
    _pickerValues = [NSArray arrayWithObjects:@"Very wet", @"Wet", @"Normal", @"Dry", @"Very dry", nil];
    
    self.lowCalibrationValue = lowCalibrationValue;
    self.highCalibrationValue = highCalibrationValue;
    
    self.saveBlock = saveBlock;
    self.cancelBlock = cancelBlock;
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    self.frame = screenFrame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    [[NSBundle mainBundle] loadNibNamed:@"MoisturePickerView" owner:self options:nil];
    _pickerViewContainer.frame = CGRectMake(0.0, self.frame.size.height, self.frame.size.width, _pickerViewContainer.frame.size.height);
    [self addSubview:_pickerViewContainer];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:(7 << 16) animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        _pickerViewContainer.frame = CGRectMake(_pickerViewContainer.frame.origin.x, self.frame.size.height - _pickerViewContainer.frame.size.height, _pickerViewContainer.frame.size.width, _pickerViewContainer.frame.size.height);
    } completion:nil];
}

- (IBAction)saveAction:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        [self hide];
    } completion:^(BOOL finished) {
        if (_saveBlock) {
            float lowCalibration = [_lowCalibrationValue floatValue];
            float highCalibration = [_highCalibrationValue floatValue];
            
            float calibrationStep = (highCalibration - lowCalibration)/4;
            
            NSInteger selectedValue = [_pickerView selectedRowInComponent:0];
            switch (selectedValue) {
                case 0:
                    _saveBlock(lowCalibration + calibrationStep * 0);
                    break;
                case 1:
                    _saveBlock(lowCalibration + calibrationStep * 1);
                    break;
                case 2:
                    _saveBlock(lowCalibration + calibrationStep * 2);
                    break;
                case 3:
                    _saveBlock(lowCalibration + calibrationStep * 3);
                    break;
                case 4:
                    _saveBlock(lowCalibration + calibrationStep * 4);
                    break;
            }
        }
        [self removeFromSuperview];
    }];
}

- (IBAction)cancelAction:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        [self hide];
    } completion:^(BOOL finished) {
        if (_cancelBlock) {
            _cancelBlock();
        }
        [self removeFromSuperview];
    }];
}

- (void)hide {
    self.backgroundColor = [UIColor clearColor];
    _pickerViewContainer.frame = CGRectMake(_pickerViewContainer.frame.origin.x, self.frame.size.height, _pickerViewContainer.frame.size.width, _pickerViewContainer.frame.size.height);
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_pickerValues count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
                       titleForRow:(NSInteger)row
                      forComponent:(NSInteger)component {
    return [_pickerValues objectAtIndex:row];
}

@end
