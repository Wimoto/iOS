//
//  FirmwareCell.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "FirmwareCell.h"

@interface FirmwareCell ()

@property (nonatomic, weak) IBOutlet UILabel *sensorNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

@end

@implementation FirmwareCell

- (void)bindData:(Firmware *)firmware {
    _sensorNameLabel.text = [firmware name];
    _versionLabel.text = [firmware version];
}

@end
