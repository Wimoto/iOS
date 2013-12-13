//
//  NoSensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/12/13.
//
//

#import "NoSensorViewController.h"
#import "WimotoDeckController.h"

@interface NoSensorViewController ()

- (IBAction)addSensor:(id)sender;

@end

@implementation NoSensorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addSensor:(id)sender {
    [(WimotoDeckController*)self.viewDeckController showSearchSensorScreen];
}

@end
