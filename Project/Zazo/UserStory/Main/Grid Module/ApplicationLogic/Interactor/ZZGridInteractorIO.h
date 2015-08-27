//
//  ZZGridInteractorIO.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDomainModel;

@protocol ZZGridInteractorInput <NSObject>

- (void)loadData;
- (void)selectedPlusCellWithIndexPath:(NSIndexPath *)indexPath;
- (void)selectedUserWithModel:(id)model;
- (NSInteger)centerCellIndex;

@end


@protocol ZZGridInteractorOutput <NSObject>

- (void)dataLoadedWithArray:(NSArray*)data;
- (void)dataLoadedWithError:(NSError *)error;
- (void)modelUpdatedWithUserWithModel:(ZZGridDomainModel *)model;

@end