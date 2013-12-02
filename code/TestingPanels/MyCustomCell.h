//
//  MyCustomCell.h
//  TestingPanels
//
//  Created by Marc Nicholas on 11/17/2013.
//  Copyright (c) 2013 Marc Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MyCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *prepTimeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

@end

