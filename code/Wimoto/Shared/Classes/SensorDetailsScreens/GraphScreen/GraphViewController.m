//
//  GraphViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.12.13.
//
//

#import "GraphViewController.h"
#import "ASBSparkLineView.h"

@interface GraphViewController ()
{
    NSMutableArray *m_temperatureData;
    NSMutableArray *m_humidityData;
    NSMutableArray *m_lightData;
    NSMutableArray *temperatureValues;
    NSMutableArray *humidityValues;
    NSMutableArray *lightValues;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *sparkLineView1;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *sparkLineView2;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *sparkLineView3;

- (void)setup;
- (void)updateSensorValues;

@end

@implementation GraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sparkLineView1.labelText = @"Temp";
    self.sparkLineView1.currentValueColor = [UIColor redColor];
    
    self.sparkLineView2.labelText = @"Humidity";
    self.sparkLineView2.currentValueColor = [UIColor greenColor];
    self.sparkLineView2.penColor = [UIColor blueColor];
    self.sparkLineView2.penWidth = 3.0f;
    
    self.sparkLineView3.labelText = @"Light";
    self.sparkLineView3.currentValueColor = [UIColor orangeColor];
    self.sparkLineView3.currentValueFormat = @"%.0f";
    self.sparkLineView3.penColor = [UIColor redColor];
    self.sparkLineView3.penWidth = 6.0f;
    [self setup];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup {
    
    m_temperatureData = [[NSMutableArray alloc] init];
    m_humidityData = [[NSMutableArray alloc] init];
    m_lightData = [[NSMutableArray alloc] init];
    
    temperatureValues = [[NSMutableArray alloc] init];
    humidityValues = [[NSMutableArray alloc] init];
    lightValues = [[NSMutableArray alloc] init];
    
    NSArray *dataArray = [NSArray arrayWithObjects: m_temperatureData, m_humidityData, m_lightData, nil];
    NSArray *fileNames = [NSArray arrayWithObjects: @"temperature_data.txt", @"humidity_data.txt", @"light_data.txt", nil];
    
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
    [temperatureValues addObject:[m_temperatureData objectAtIndex:tempIndex]];
    if ([temperatureValues count] == 16) {
        [temperatureValues removeObjectAtIndex:0];
    }
    self.sparkLineView1.dataValues = temperatureValues;
    int humidityIndex = arc4random()%[m_humidityData count];
    [humidityValues addObject:[m_humidityData objectAtIndex:humidityIndex]];
    if ([humidityValues count] == 16) {
        [humidityValues removeObjectAtIndex:0];
    }
    self.sparkLineView2.dataValues = humidityValues;
    int lightIndex = arc4random()%[m_lightData count];
    [lightValues addObject:[m_lightData objectAtIndex:lightIndex]];
    if ([lightValues count] == 16) {
        [lightValues removeObjectAtIndex:0];
    }
    self.sparkLineView3.dataValues = lightValues;

}

@end
