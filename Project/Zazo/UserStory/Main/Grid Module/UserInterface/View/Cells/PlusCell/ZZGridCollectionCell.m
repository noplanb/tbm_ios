//
//  ZZGridCollectionCell.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionCell.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridCellViewModel.h"

@interface ZZGridCollectionCell () <ZZUserRecorderGridViewDelegate>

@property (nonatomic, strong) ZZGridCellViewModel* gridModel;
@property (nonatomic, strong) UIImageView* plusImageView;

@property (nonatomic, strong) UIGestureRecognizer* plusRecognizer;
@property (nonatomic, strong) UIImage* screenShot;
@property (nonatomic, strong) UIView* containFriendView;

@end

@implementation ZZGridCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor orangeColor];
        [self plusImageView];
        [self containFriendView];
    }
    return self;
}

- (void)prepareForReuse
{
    [self.recorderView removeFromSuperview];
}

- (void)updateWithModel:(id)model
{
    self.gridModel = nil;
    self.gridModel = model;
    
    [self _updateIfNeededStateWithUserModel:self.gridModel];
}

- (id)model
{
    return self.gridModel;
}

- (UIImageView *)plusImageView
{
    if (!_plusImageView)
    {
        _plusImageView = [UIImageView new];
        _plusImageView.image = [UIImage imageNamed:@"icons-plus-1x"];
        _plusImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_plusImageView];
        
        [_plusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return _plusImageView;
}

- (void)_updateIfNeededStateWithUserModel:(ZZGridCellViewModel *)model
{
    if (model.domainModel.relatedUser)
    {
        self.recorderView = [[ZZUserRecorderGridView alloc] initWithPresentedView:self withModel:model];
    }
    else
    {
        [self.recorderView removeFromSuperview];
    }
}

#pragma mark - Not Logged View Delegate

- (void)nudgePressed
{
    [self.gridModel nudgeSelected];
}

- (void)startRecording
{
    [self.gridModel startRecordingWithView:self];
}

- (void)stopRecording
{
    [self.gridModel stopRecording];
}

- (void)makeActualScreenShoot
{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (UIImage *)actualSateImage
{
    return self.screenShot;
}

- (void)showContainFriendAnimation
{
    [self.recorderView showContainFriendAnimation];
}


@end
