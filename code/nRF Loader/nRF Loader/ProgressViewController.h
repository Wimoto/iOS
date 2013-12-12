//
//  ProgressViewController.h
//  nRF Loader
//
//  Created by Ole Morten on 11/6/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFUController.h"

@interface ProgressViewController : UIViewController <DFUControllerDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property DFUController *dfuController;

@end
