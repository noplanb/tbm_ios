//
//  ZZGridCollectionCell.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCell.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridCellViewModel.h"
#import "UIImage+PDF.h"
#import "TBMVideoRecorder.h"
#import "ZZVideoRecorder.h"
#import "ZZGridStateView.h"
#import "ZZGridCellStateViewBuilder.h"

#import "ZZGridCollectionNudgeStateView.h"
#import "ZZGridCollectionCellRecordStateView.h"
#import "ZZGridCollectionCellPreviewStateView.h"

@interface ZZGridCell () <ZZGridCollectionCellBaseStateViewDelegate>

@property (nonatomic, strong) ZZGridCellViewModel* model;
@property (nonatomic, strong) UIImageView* plusImageView;
@property (nonatomic, strong) UIGestureRecognizer* plusRecognizer;
@property (nonatomic, strong) ZZGridStateView* stateView;

@end

@implementation ZZGridCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor orangeColor];
        [self plusImageView];
    }
    return self;
}

- (void)prepareForReuse
{
    [self.stateView removeFromSuperview];
    [self stopVideoPlaying];
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
       
        self.model = model;
    
        switch (model.state)
        {
            case ZZGridCellViewModelStateAdd:
            {
                [self.stateView removeFromSuperview];
            } break;
            case ZZGridCellViewModelStateFriendHasApp:
            {
                self.stateView = [[ZZGridCollectionCellRecordStateView alloc] initWithPresentedView:self
                                                                                          withModel:model];
            } break;
            case ZZGridCellViewModelStateFriendHasNoApp:
            {
                self.stateView = [[ZZGridCollectionNudgeStateView alloc] initWithPresentedView:self
                                                                                     withModel:model];
            } break;
            case ZZGridCellViewModelStateIncomingVideoNotViewed:
            {
                //TODO:
                self.stateView = [[ZZGridCollectionCellPreviewStateView alloc] initWithPresentedView:self
                                                                                           withModel:model];
            } break;
            case ZZGridCellViewModelStateIncomingVideoViewed:
            {//TODO:
                self.stateView = [[ZZGridCollectionCellPreviewStateView alloc] initWithPresentedView:self
                                                                                           withModel:model];
            } break;
            case ZZGridCellViewModelStateOutgoingVideo:
            {//TODO:
                self.stateView = [[ZZGridCollectionCellPreviewStateView alloc] initWithPresentedView:self
                                                                                           withModel:model];
            } break;
            default: break;
        }
    });
}


#pragma mark - Not Logged View Delegate

//- (void)nudgePressed
//{
//    [self.model nudgeSelected];
//}
//
//- (void)startRecording
//{
//    [self.model startRecordingWithView:self];
//}
//
//- (void)stopRecording
//{
//    [self.model stopRecording];
//}

- (void)setStateView:(ZZGridStateView*)stateView
{
    if (_stateView != stateView)
    {
        [_stateView removeFromSuperview];
        _stateView = stateView;
    }
    [self.contentView addSubview:stateView];
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)makeActualScreenShoot
{
    if (![self.stateView isVideoPlayerPlaying])
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, scale);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.model.screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (UIImage *)actualSateImage
{
    return self.model.screenShot;
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



- (UIImageView*)plusImageView
{
    if (!_plusImageView)
    {
        _plusImageView = [UIImageView new];
        _plusImageView.image = [[UIImage imageWithPDFNamed:@"icon_plus" atHeight:50]
                                an_imageByTintingWithColor:[UIColor whiteColor]];
        _plusImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_plusImageView];
        
        [_plusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _plusImageView;
}

@end
