//
//  ZZRecordingView.m
//  Zazo
//
//  Created by Rinat on 15/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZRecordingView.h"

@implementation ZZRecordingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionOverrideInheritedDuration
                     animations:^{
                         self.recordIndicator.alpha = 0;
                     }
                     completion:nil];
}

@end
