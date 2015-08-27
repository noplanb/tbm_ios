//
//  ZZUserNotLoggedGridView.h
//  Zazo
//
//  Created by ANODA on 14/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* kLayoutConstGreenColor = @"9BC046";

@class ZZFriendDomainModel;

@protocol ZZUserRecorderGridViewDelegate  <NSObject>

- (void)nudgePressed;
- (void)startRecording;
- (void)stopRecording;

@end

@interface ZZUserRecorderGridView : UIView

@property (nonatomic, strong) UIImageView* uploadingIndicator;
@property (nonatomic, strong) MASConstraint* leftUploadIndicatorConstraint;
@property (nonatomic, strong) UIView* uploadBarView;


@property (nonatomic, strong) UIImageView* downloadIndicator;
@property (nonatomic, strong) MASConstraint* rightDownloadIndicatorConstraint;
@property (nonatomic, strong) UIView* downloadBarView;

@property (nonatomic, strong) UILabel* videoCountLabel;

- (instancetype)initWithPresentedView:(UIView <ZZUserRecorderGridViewDelegate> *)presentedView
                      withFriendModel:(ZZFriendDomainModel *)friendModel;
- (void)showUploadAnimation;
- (void)showDownloadAnimationWithNewVideoCount:(NSInteger)count;

@end
