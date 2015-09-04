//
//  ZZGridCollectionCell.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionCell.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridCollectionCellViewModel.h"
#import "UIImage+PDF.h"
#import "TBMVideoRecorder.h"
#import "ZZVideoRecorder.h"
#import "ZZGridCollectionCellBaseStateView.h"
#import "ZZGridCollectionCellStateViewFactory.h"


@interface ZZGridCollectionCell () <ZZGridCollectionCellBaseStateViewDelegate>

@property (nonatomic, strong) ZZGridCollectionCellViewModel* gridModel;
@property (nonatomic, strong) UIImageView* plusImageView;
@property (nonatomic, strong) UIGestureRecognizer* plusRecognizer;
@property (nonatomic, strong) ZZGridCollectionCellBaseStateView* stateView;
@property (nonatomic, strong) ZZGridCollectionCellStateViewFactory* stateViewFactory;

@end

@implementation ZZGridCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor orangeColor];
        [self plusImageView];
        self.stateViewFactory = [ZZGridCollectionCellStateViewFactory new];
        
    }
    return self;
}

- (void)prepareForReuse
{
    [self.stateView removeFromSuperview];
    [self stopVideoPlaying];
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
        
        CGSize size = CGSizeMake(50, 50);
        _plusImageView.image = [[UIImage imageWithPDFNamed:@"icon_plus" atSize:size]
                                an_imageByTintingWithColor:[UIColor whiteColor]];
        _plusImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_plusImageView];
        
        [_plusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return _plusImageView;
}

- (void)_updateIfNeededStateWithUserModel:(ZZGridCollectionCellViewModel *)model
{
    if (model.item.relatedUser)
    {
        self.stateView = [self.stateViewFactory stateViewWithPresentedView:self withCellViewModel:model];
    }
    else
    {
        [self.stateView removeFromSuperview];
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
    if (![self.stateView isVideoPlayerPalying])
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, scale);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.gridModel.screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (UIImage *)actualSateImage
{
    return self.gridModel.screenShot;
}


#pragma mark - Animation part

- (void)showContainFriendAnimation
{
    [self.stateView showContainFriendAnimation];
}

- (void)showUploadVideoAnimationWithCount:(NSInteger)count
{
    [self.stateView showDownloadAnimationWithNewVideoCount:count];
}

- (void)videoDownloadedWithUrl:(NSURL *)videoUrl
{
    [self.stateView setupPlayerWithUrl:videoUrl];
}

#pragma mark - Video Player part

- (void)stopVideoPlaying
{
    [self.stateView stopPlayVideo];
}

- (void)startVidePlay
{
    [self.stateView startPlayVideo];
}

@end
