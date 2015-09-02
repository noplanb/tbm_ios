//
//  ZZGridCellViewModel.h
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZGridDomainModel.h"


@protocol ZZGridCellViewModellDelegate <NSObject>

- (void)startRecordingWithView:(id)view;
- (void)stopRecording;
- (void)nudgeSelectedWithUserModel:(id)userModel;

@end

@interface ZZGridCollectionCellViewModel : NSObject

@property (nonatomic, weak) id <ZZGridCellViewModellDelegate> delegate;
@property (nonatomic, strong) ZZGridDomainModel* domainModel;
@property (nonatomic, strong) NSNumber* badgeNumber;

- (void)startRecordingWithView:(UIView *)view;
- (void)stopRecording;
- (void)nudgeSelected;

@end
