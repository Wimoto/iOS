//
//  leftViewController.m
//  TestingPanels
//
//  Created by Marc Nicholas on 11/18/2013.
//  Copyright (c) 2013 Marc Nicholas. All rights reserved.
//

#import "leftViewController.h"

@interface leftViewController ()

@end

@implementation leftViewController
{
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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


-(IBAction)helpButtonTapped:(UIButton *)sender
{
        NSLog(@"Help! Help!");
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.wimoto.com"]];
}

@end
