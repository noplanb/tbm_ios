//
//  ZZGridCollectionCellBaseStateView+Animation.h
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateView.h"

@interface ZZGridStateView (Animation)

- (void)_showUploadAnimationWithCompletionBlock:(void(^)())completionBlock;
- (void)_showVideoCountLabelWithCount:(NSInteger)count;
- (void)_hideVideoCountLabel;
- (void)_showUploadIconWithoutAnimation;
- (void)_hideAllAnimationViews;
- (void)_showDownloadAnimationWithCompletionBlock:(void (^)())completionBlock;

@end
