//
//  ZZGridInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridCellViewModel, ZZFriendDomainModel, ANMessageDomainModel;

@protocol ZZGridInteractorInput <NSObject>

- (void)loadData;
- (void)selectedPlusCellWithModel:(ZZGridCellViewModel*)model;
- (void)selectedUserWithModel:(id)model;
- (NSInteger)centerCellIndex;
- (void)loadFeedbackModel;

@end


@protocol ZZGridInteractorOutput <NSObject>

- (void)dataLoadedWithArray:(NSArray*)data;
- (void)dataLoadedWithError:(NSError *)error;
- (void)modelUpdatedWithUserWithModel:(ZZGridCellViewModel *)model;
- (void)gridContainedFriend:(ZZFriendDomainModel*)friendModel;
- (void)loadedFeedbackDomainModel:(ANMessageDomainModel*)model;

@end