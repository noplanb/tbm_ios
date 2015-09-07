//
//  ZZGridCollectionCellPreviewView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCollectionCellPreviewStateView.h"

@interface ZZGridCollectionCellPreviewStateView ()

@property (nonatomic, strong) UIImageView* thumbnailImageView;
@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UIImage* thumbnailImage;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic, assign) BOOL isVideoPlaying;

@end

@implementation ZZGridCollectionCellPreviewStateView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self _setupRecognizer];
        [self thumbnailImageView];
        [self userNameLabel];
        [self containFriendView];
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    self.thumbnailImage = [self _generateThumbWithVideoUrl:[[model.item.relatedUser.videos allObjects] firstObject]];// TODO: for test
}


#pragma mark - Lazy Load

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
