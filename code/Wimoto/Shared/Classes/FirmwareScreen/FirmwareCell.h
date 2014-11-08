//
//  FirmwareCell.h
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import <UIKit/UIKit.h>
#import "Firmware.h"

@interface FirmwareCell : UITableViewCell

- (void)bindData:(Firmware *)firmware;

@end
