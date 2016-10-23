//
//  ZZGridCollectionCell.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCellViewModel.h"
#import "ANModelTransfer.h"

@interface ZZGridCell : UIView <ANModelTransfer>

- (void)showContainFriendAnimation;
- (void)hideAllAnimations;
//- (void)hideActiveBorder;
- (void)setBadgesHidden:(BOOL)hidden;
- (void)setDownloadProgress:(CGFloat)progress;
- (void)showSentAnimation;

@end
