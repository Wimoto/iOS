//
//  FirmwareUploadViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "FirmwareUploadViewController.h"

@interface FirmwareUploadViewController ()

@property (nonatomic, strong) DFUController *dfuController;

@end

@implementation FirmwareUploadViewController

- (id)initWithDFUController:(DFUController *)dfuController {
    self = [super init];
    if (self) {
        self.dfuController = dfuController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Firmware upload";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
