//
//  WimotoDeckController.m
//  Wimoto
//
//  Created by MC700 on 12/12/13.
//
//

#import "WimotoDeckController.h"
#import "SearchSensorViewController.h"

@interface WimotoDeckController ()

@end

@implementation WimotoDeckController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSearchSensorScreen {
    self.centerController = [[SearchSensorViewController alloc] init];
}

@end
