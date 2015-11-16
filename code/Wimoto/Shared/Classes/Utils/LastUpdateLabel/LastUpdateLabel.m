//
//  LastUpdateLabel.m
//  Wimoto
//
//  Created by Mobitexoft on 12.10.15.
//
//

#import "LastUpdateLabel.h"
#import "RelativeDateDescriptor.h"

@implementation LastUpdateLabel

- (void) dealloc {
    [self reset];
}

- (void)reset {
    if ([self.lastUpdateTimer isValid]) {
        [self.lastUpdateTimer invalidate];
    }
    self.lastUpdateTimer = nil;
}

- (void)refresh {
    self.text = @"Just now";
    if ([self.lastUpdateTimer isValid]) {
        [self.lastUpdateTimer invalidate];
    }
    
    self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdate) userInfo:nil repeats:YES];
}

- (void)refreshLastUpdate {
    NSDate *lastUpdateDate = [_sensor.entity lastActivityAt];
    if (lastUpdateDate) {
        RelativeDateDescriptor *descriptor = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@ ago" postDateDescriptionFormat:@"in %@"];
        self.text = [descriptor describeDate:lastUpdateDate relativeTo:[NSDate date]];
    }
}

@end
