//
//  ThermoSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ThermoSensorDetailsViewController.h"

@interface ThermoSensorDetailsViewController ()
{
    NSMutableArray *m_tempProbeData;
    NSMutableArray *m_tempIRData;
    NSMutableArray *m_bluetoothData;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) IBOutlet UILabel *tempProbeLabel;
@property (nonatomic, weak) IBOutlet UILabel *tempIRLabel;
@property (nonatomic, weak) IBOutlet UILabel *bluetoothLabel;

- (void)setup;
- (void)updateSensorValues;

@end

@implementation ThermoSensorDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self) {
        [self setup];
    }
    // Do any additional setup after loading the view from its nib.
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
    
    m_tempProbeData = [[NSMutableArray alloc] init];
    m_tempIRData = [[NSMutableArray alloc] init];
    m_bluetoothData = [[NSMutableArray alloc] init];
    
    NSArray *dataArray = [NSArray arrayWithObjects: m_tempProbeData, m_tempIRData, m_bluetoothData, nil];
    NSArray *fileNames = [NSArray arrayWithObjects: @"thermoProbe_data.txt", @"thermoIR_data.txt", @"bluetooth_data.txt", nil];
    
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
    int tempProbeIndex = arc4random()%[m_tempProbeData count];
    _tempProbeLabel.text = [NSString stringWithFormat:@"%@", [m_tempProbeData objectAtIndex:tempProbeIndex]];
    int tempIRIndex = arc4random()%[m_tempIRData count];
    _tempIRLabel.text = [NSString stringWithFormat:@"%@", [m_tempIRData objectAtIndex:tempIRIndex]];
    int bluetoothIndex = arc4random()%[m_bluetoothData count];
    _bluetoothLabel.text = [NSString stringWithFormat:@"-%@db", [m_bluetoothData objectAtIndex:bluetoothIndex]];
}

@end
