//
//  ZZGridCollectionCell.m
//  Zazo
//
//  Created by ANODA.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionCell.h"
#import "ZZUserRecorderGridView.h"
#import "ZZGridDomainModel.h"
#import "ZZFriendDomainModel.h"


@interface ZZGridCollectionCell () <ZZUserRecorderGridViewDelegate>

@property (nonatomic, strong) ZZGridDomainModel* gridModel;
@property (nonatomic, strong) UIImageView* plusImageView;
@property (nonatomic, strong) ZZUserRecorderGridView* recorderView;

@end

@implementation ZZGridCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor orangeColor];
        [self plusImageView];
    }
    return self;
}

- (void)updateWithModel:(id)model
{
    self.gridModel = model;
    [self _updateIfNeededStateWithUserModel:self.gridModel.relatedUser];
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

- (void)_updateIfNeededStateWithUserModel:(ZZFriendDomainModel *)model
{
    if (model)
    {
        self.recorderView = [[ZZUserRecorderGridView alloc] initWithPresentedView:self withFriendModel:model];
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

@end
