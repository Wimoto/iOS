//
//  FirmwareCell.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "FirmwareCell.h"

@interface FirmwareCell ()

@property (nonatomic, weak) IBOutlet UILabel *fileNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel;

@end

@implementation FirmwareCell

- (void)bindData:(NSDictionary *)dictionary {
    _fileNameLabel.text = [dictionary objectForKey:@"title"];
    _sizeLabel.text = [NSString stringWithFormat:@"%@ bytes", [dictionary objectForKey:@"size"]];
}

@end
