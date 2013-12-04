//
//  ClimateSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ClimateSensorDetailsViewController.h"

@interface ClimateSensorDetailsViewController () {
    NSMutableArray *m_temperatureData;
    NSMutableArray *m_humidityData;
    NSMutableArray *m_lightData;
    NSMutableArray *m_bluetoothData;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) IBOutlet UILabel *tempLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;
@property (nonatomic, weak) IBOutlet UILabel *bluetoothLabel;

- (void)setup;
- (void)updateSensorValues;

@end

@implementation ClimateSensorDetailsViewController
@synthesize sparklineTemperature;


const float tempMinLimit = 36.9f;
const float tempMaxLimit = 37.4f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self) {
        [self setup];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_timer invalidate];
}

- (void)setup {
    
    m_temperatureData = [[NSMutableArray alloc] init];
    m_humidityData = [[NSMutableArray alloc] init];
    m_lightData = [[NSMutableArray alloc] init];
    m_bluetoothData = [[NSMutableArray alloc] init];
    
    NSArray *dataArray = [NSArray arrayWithObjects: m_temperatureData, m_humidityData, m_lightData, m_bluetoothData, nil];
    NSArray *fileNames = [NSArray arrayWithObjects: @"temperature_data.txt", @"humidity_data.txt", @"light_data.txt", @"bluetooth_data.txt", nil];
    
    [fileNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // read in the dummy data and allocate to the appropriate view
        NSError *err;
        NSString *dataFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:obj];
        NSString *contents = [[NSString alloc] initWithContentsOfFile:dataFile encoding:NSUTF8StringEncoding error:&err];
        
        if (contents) {
            
            NSScanner *scanner = [[NSScanner alloc] initWithString:contents];
            
            NSMutableArray *data = [dataArray objectAtIndex:idx];
            while ([scanner isAtEnd] == NO) {
                float scannedValue = 0;
                if ([scanner scanFloat:&scannedValue]) {
                    NSNumber *num = [[NSNumber alloc] initWithFloat:scannedValue];
                    [data addObject:num];
                }
            }
            if ([fileNames count]-1 == idx) {
                [self updateSensorValues];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateSensorValues) userInfo:nil repeats:YES];
            }
            
        } else {
            NSLog(@"failed to read in data file %@: %@", [fileNames objectAtIndex:idx], [err localizedDescription]);
        }
        
    }];
    
}

- (void)updateSensorValues
{
    int tempIndex = arc4random()%[m_temperatureData count];
    _tempLabel.text = [NSString stringWithFormat:@"%@", [m_temperatureData objectAtIndex:tempIndex]];
    int humidityIndex = arc4random()%[m_humidityData count];
    _humidityLabel.text = [NSString stringWithFormat:@"%@", [m_humidityData objectAtIndex:humidityIndex]];
    int lightIndex = arc4random()%[m_lightData count];
    _lightLabel.text = [NSString stringWithFormat:@"%@", [m_lightData objectAtIndex:lightIndex]];
    int bluetoothIndex = arc4random()%[m_bluetoothData count];
    _bluetoothLabel.text = [NSString stringWithFormat:@"-%@db", [m_bluetoothData objectAtIndex:bluetoothIndex]];
}

@end
