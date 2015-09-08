//
//  ZZGridCollectionCellBaseView.h
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCellViewModel.h"
#import "ANModelTransfer.h"

@class ZZGridCellViewModel;

@interface ZZGridStateView : UIView <ANModelTransfer>

@property (nonatomic, strong) UIView* containFriendView;

@property (nonatomic, strong) ZZGridCellViewModel* model;
@property (nonatomic, strong) UIImageView* uploadingIndicator;
@property (nonatomic, strong) MASConstraint* leftUploadIndicatorConstraint;
@property (nonatomic, strong) UIView* uploadBarView;

@property (nonatomic, strong) UIImageView* downloadIndicator;
@property (nonatomic, strong) MASConstraint* rightDownloadIndicatorConstraint;
@property (nonatomic, strong) UIView* downloadBarView;
@property (nonatomic, strong) UILabel* videoCountLabel;

- (void)updateBadgeWithNumber:(NSNumber*)badgeNumber;
- (void)showUploadAnimation;
- (void)showDownloadAnimationWithNewVideoCount:(NSInteger)count;
- (void)showContainFriendAnimation;
- (void)showUploadIconWithoutAnimation;

@end
