//
//  AppTableViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "AppTableViewController.h"

@interface AppTableViewController ()

@end

@implementation AppTableViewController

- (id)init
{
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
    self = [super initWithNibName:[NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), (isIpad)?@"iPad":@"iPhone"] bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
