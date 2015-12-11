//
//  ZZEditFriendCellViewModel.h
//  Zazo
//
//  Created by ANODA on 8/25/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDomainModel.h"
#import "ZZEditFriendEnumsAdditions.h"

typedef NS_ENUM(NSInteger, ZZEditFriendButtonType)
{
    ZZEditFriendButtonTypeDelete,
    ZZEditFriendButtonTypeRestore
};

@class ZZEditFriendCellViewModel;

@protocol ZZEditFriendCellViewModelDelegate <NSObject>

- (void)deleteAndRestoreButtonSelectedWithModel:(ZZEditFriendCellViewModel *)model;

@end

@interface ZZEditFriendCellViewModel : NSObject

@property (nonatomic, weak) id<ZZEditFriendCellViewModelDelegate> delegate;
@property (nonatomic, strong) ZZFriendDomainModel* item; //TODO: domain models should be short lived

@property (nonatomic, assign) BOOL isUpdating;

- (void)updatePhotoImageView:(UIImageView *)imageView;
- (void)updateDeleteButton:(UIButton *)button;

- (NSString *)username;
- (NSString *)phoneNumber;
- (UIColor *)cellBackgroundColor;

- (void)deleteAndRestoreButtonSelected;

@end
