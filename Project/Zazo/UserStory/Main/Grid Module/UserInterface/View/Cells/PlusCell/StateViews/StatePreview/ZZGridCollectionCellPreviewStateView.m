//
//  ZZGridCollectionCellPreviewView.m
//  Zazo
//
//  Created by Dmitriy Frolow on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

#import "ZZGridCollectionCellPreviewStateView.h"

@interface ZZGridCollectionCellPreviewStateView ()

@property (nonatomic, strong) UIImageView* thumbnailImageView;
@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UIImage* thumbnailImage;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic, assign) BOOL isVideoPlaying;

@end

@implementation ZZGridCollectionCellPreviewStateView

- (instancetype)initWithPresentedView:(UIView<ZZGridCollectionCellBaseStateViewDelegate> *)presentedView withModel:(ZZGridCollectionCellViewModel *)cellViewModel
{
    self = [super initWithPresentedView:presentedView withModel:cellViewModel];
    
    if (self)
    {
        [self _setupRecognizer];
        [self setupPlayerWithUrl:[[cellViewModel.domainModel.relatedUser.videos allObjects] firstObject]];
        self.thumbnailImage = [self _generateThumbWithVideoUrl:[[cellViewModel.domainModel.relatedUser.videos allObjects] firstObject]];// TODO: for test
        [self thumbnailImageView];
        [self userNameLabel];
        [self containFriendView];
    }
    
    return self;
}

- (UIImageView *)thumbnailImageView
{
    if (!_thumbnailImageView)
    {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.image = self.thumbnailImage;
        _thumbnailImageView.backgroundColor = [UIColor whiteColor];
        _thumbnailImageView.userInteractionEnabled = YES;
        [_thumbnailImageView addGestureRecognizer:self.tapRecognizer];
        [self addSubview:_thumbnailImageView];
        
        [_thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return _thumbnailImageView;
}

- (UILabel *)userNameLabel
{
    if (!_userNameLabel)
    {
        _userNameLabel = [UILabel new];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.text = self.friendModel.firstName;
        _userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        [self addSubview:_userNameLabel];
        
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@(CGRectGetHeight(self.presentedView.frame)/kUserNameScaleValue));
        }];
    }
    return _userNameLabel;
}

- (UIImage *)_generateThumbWithVideoUrl:(NSURL *)videoUrl{
    
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime duration = asset.duration;
    CMTime secondsFromEnd = CMTimeMake(2, 1);
    CMTime thumbTime = CMTimeSubtract(duration, secondsFromEnd);
    CMTime actual;
    NSError *err = nil;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbTime actualTime:&actual error:&err];
    if (err != nil){
        OB_ERROR(@"generateThumb: %@", err);
        return NO;
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return thumbnail;
}

- (void)_setupRecognizer
{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_startVideo:)];
}

- (void)_startVideo:(UITapGestureRecognizer *)recognizer
{
    if (!self.superview.isHidden)
    {
        [self startPlayVideo];
    }
}

@end
