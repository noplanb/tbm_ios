//
//  ZZEditFriendCellViewModel.h
//  Zazo
//
//  Created by ANODA on 8/25/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDomainModel.h"
#import "ZZEditFriendEnumsAdditions.h"

@class ZZEditFriendCellViewModel;

@protocol ZZEditFriendCellViewModelDelegate <NSObject>

- (void)switchValueChangedWithModel:(ZZEditFriendCellViewModel *)model;

@end

@interface ZZEditFriendCellViewModel : NSObject

@property (nonatomic, weak) id<ZZEditFriendCellViewModelDelegate> delegate;
@property (nonatomic, strong) ZZFriendDomainModel* item;

@property (nonatomic, assign) BOOL isUpdating;

- (void)updatePhotoImageView:(UIImageView *)imageView;
- (void)updateSwitch:(UISwitch *)aSwitch;

- (NSString *)username;
- (NSString *)abbreviation;

- (NSString *)phoneNumber;

- (void)switchStateChanged;

@end
