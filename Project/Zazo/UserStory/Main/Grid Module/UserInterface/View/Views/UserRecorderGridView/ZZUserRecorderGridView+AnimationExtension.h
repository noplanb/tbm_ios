//
//  ZZUserRecorderGridView+AnimationExtension.h
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserRecorderGridView.h"

@interface ZZUserRecorderGridView (AnimationExtension)

- (void)_showUploadAnimation;
- (void)_showDownloadAnimationWithNewVideoCount:(NSInteger)count;
- (void)_showVideoCountLabelWithCount:(NSInteger)count;
- (void)_hideVieoCountLabel;

@end
