//
//  FirmwareUploadViewController.h
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "AppViewController.h"
#import "DFUController.h"

@interface FirmwareUploadViewController : AppViewController <DFUControllerDelegate>

- (id)initWithDFUController:(DFUController *)dfuController;

@end
