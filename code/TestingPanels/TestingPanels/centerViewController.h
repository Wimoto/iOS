//
//  centerViewController.h
//  TestingPanels
//
//  Created by Marc Nicholas on 11/18/2013.
//  Copyright (c) 2013 Marc Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"

@interface centerViewController : UIViewController

@property (weak, nonatomic) IBOutlet NMRangeSlider *standardSlider;
@property (weak, nonatomic) IBOutlet NMRangeSlider *metalSlider;
@property (weak, nonatomic) IBOutlet NMRangeSlider *singleThumbSlider;
@property (weak, nonatomic) IBOutlet NMRangeSlider *steppedSlider;
@property (weak, nonatomic) IBOutlet NMRangeSlider *steppedContinuouslySlider;
@property (weak, nonatomic) IBOutlet NMRangeSlider *setValuesSlider;
@property (weak, nonatomic) IBOutlet NMRangeSlider *crossOverSlider;

@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *programaticallyContainerCell;

- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;
@end
