//
//  WPTemperatureView.m
//  Wimoto
//
//  Created by Mobitexoft on 15.05.15.
//
//

#import "WPTemperatureView.h"
#import "WPTemperatureValueLabel.h"

@interface WPTemperatureView()

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *temperatureLabel;

@end

@implementation WPTemperatureView

- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSBundle mainBundle] loadNibNamed:@"WPTemperatureView" owner:self options:nil];
    [self addSubview:_contentView];
    _contentView = nil;
}

- (void)setText:(NSString *)text {
    [_temperatureLabel setText:text];
}

- (void)setTemperature:(float)temperature {
    [_temperatureLabel setTemperature:temperature];
}

- (IBAction)switchMeasureAction:(id)sender {
    NSString *cOrFString = [[NSUserDefaults standardUserDefaults] objectForKey:@"cOrF"];
    cOrFString = [cOrFString isEqualToString:@"C"]?@"F":@"C";
    
    [[NSUserDefaults standardUserDefaults] setObject:cOrFString forKey:@"cOrF"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
