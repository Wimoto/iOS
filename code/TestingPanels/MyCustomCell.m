//
//  MyCustomCell.m
//  TestingPanels
//
//  Created by Marc Nicholas on 11/17/2013.
//  Copyright (c) 2013 Marc Nicholas. All rights reserved.
//

#import "MyCustomCell.h"
#import "centerViewController.h"

@implementation MyCustomCell

@synthesize nameLabel = _nameLabel;
@synthesize prepTimeLabel = _prepTimeLabel;
@synthesize thumbnailImageView = _thumbnailImageView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    NSLog(@"Pushed");
    
    
    // Configure the view for the selected state
}

@end
