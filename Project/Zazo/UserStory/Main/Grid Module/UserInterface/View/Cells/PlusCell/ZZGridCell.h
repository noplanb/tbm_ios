//
//  ZZGridCollectionCell.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANModelTransfer.h"

@interface ZZGridCell : UIView <ANModelTransfer>

- (void)showContainFriendAnimation;
- (void)showDownloadAnimationWithCompletionBlock:(void(^)())completionBlock;
- (void)hideAllAnimations;

@end
