//
//  ZZGridDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseDomainModel.h"

@class ZZFriendDomainModel;

@protocol ZZGridDomainModelDelegate <NSObject>

- (void)startRecordingWithView:(id)view;
- (void)stopRecording;
- (void)nudgeSelectedWithUserModel:(id)userModel;

@end


@interface ZZGridDomainModel : ZZBaseDomainModel

@property (nonatomic, weak) id <ZZGridDomainModelDelegate> delegate;
@property (nonatomic, strong) NSNumber* index;
@property (nonatomic, strong) ZZFriendDomainModel* relatedUser;

- (void)startRecordingWithView:(UIView *)view;
- (void)stopRecording;
- (void)nudgeSelected;

@end
