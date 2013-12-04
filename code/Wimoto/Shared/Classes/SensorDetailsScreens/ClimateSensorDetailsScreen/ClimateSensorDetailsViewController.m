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
}

- (void)setup;

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

- (void)setup {
    
    m_temperatureData = [[NSMutableArray alloc] init];
    
    NSArray *dataArray = [NSArray arrayWithObjects: m_temperatureData, nil];
    NSArray *fileNames = [NSArray arrayWithObjects: @"temperature_data.txt", nil];
    
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
            
        } else {
            NSLog(@"failed to read in data file %@: %@", [fileNames objectAtIndex:idx], [err localizedDescription]);
        }
        
    }];
    
}

@end
