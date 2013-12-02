//
//  MySidePanelController.m
//  TestingPanels
//
//  Created by Marc Nicholas on 11/17/2013.
//  Copyright (c) 2013 Marc Nicholas. All rights reserved.
//

#import "MySidePanelController.h"
#import "JASidePanelController.h"

@interface MySidePanelController ()

@end

@implementation MySidePanelController

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

-(void) awakeFromNib
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"centerViewController"]];
    [self setRightPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"rightViewController"]];

    
}

@end
