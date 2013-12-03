//
//  AppViewController.m
//  Wimoto
//
//  Created by MC700 on 7/30/13.
//
//

#import "AppViewController.h"

@interface AppViewController ()

@end

@implementation AppViewController

- (id)init
{
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
    self = [super initWithNibName:[NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), (isIpad)?@"_iPad":@"_iPhone"] bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
