//
//  ViewController.h
//  nRF Loader
//
//  Created by Ole Morten on 10/8/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFUController.h"

@interface TargetSelectionViewController : UIViewController <CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanActivityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *targetTableView;
@property (strong, nonatomic) IBOutlet UIView *scanButton;

@property DFUController *dfuController;

- (IBAction)scanButtonPressed:(id)sender;

@end
