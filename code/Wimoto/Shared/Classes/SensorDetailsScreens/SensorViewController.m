//
//  SensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "SensorViewController.h"

@interface SensorViewController ()

@property (nonatomic, weak) IBOutlet UILabel *rssiLabel;

@end

@implementation SensorViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super init];
    if (self) {
        _sensor = sensor;
        
        [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_sensor.rssi) {
        _rssiLabel.text = [NSString stringWithFormat:@"%@dB", _sensor.rssi];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_rangeSlider) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePicker:)];
        [toolbar setItems:[NSArray arrayWithObjects:flex, doneButton, nil]];
        
        self.rangeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, toolbar.frame.size.height + 60.0)];
        _rangeContainer.backgroundColor = [UIColor whiteColor];
        [_rangeContainer addSubview:toolbar];
        
        self.rangeSlider = [[NMRangeSlider alloc] init];
        _rangeSlider.frame = CGRectMake(10.0, toolbar.frame.origin.x + toolbar.frame.size.height, self.view.frame.size.width - 20.0, 34.0);
        _rangeSlider.minimumValue = 0;
        _rangeSlider.maximumValue = 100;
        
        _rangeSlider.lowerValue = 0;
        _rangeSlider.upperValue = 100;
        
        _rangeSlider.minimumRange = 10;
        
        [_rangeContainer addSubview:_rangeSlider];
        [self.view addSubview:_rangeContainer];
    }
    
    /*
    if (!_pickerView) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePicker:)];
        [toolbar setItems:[NSArray arrayWithObjects:flex, doneButton, nil]];
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height, self.view.frame.size.width, 216)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        self.pickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, toolbar.frame.size.height + _pickerView.frame.size.height)];
        _pickerContainer.backgroundColor = [UIColor whiteColor];
        [_pickerContainer addSubview:toolbar];
        [_pickerContainer addSubview:_pickerView];
        [self.view addSubview:_pickerContainer];
    }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI];
}

- (void)showSlider
{
    [UIView animateWithDuration:0.3 animations:^{
        _rangeContainer.frame = CGRectMake(_rangeContainer.frame.origin.x, self.view.frame.size.height - _rangeContainer.frame.size.height, _rangeContainer.frame.size.width, _rangeContainer.frame.size.height);
    }];
}

- (void)hideSlider:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _rangeContainer.frame = CGRectMake(_rangeContainer.frame.origin.x, self.view.frame.size.height, _rangeContainer.frame.size.width, _rangeContainer.frame.size.height);
    }];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_RSSI]) {
        _rssiLabel.text = [NSString stringWithFormat:@"%@dB", [change objectForKey:NSKeyValueChangeNewKey]];
    }
}

@end
