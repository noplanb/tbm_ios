//
//  ZZSecretInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretEnums.h"
@class ZZSettingsModel;


@protocol ZZSecretInteractorInput <NSObject>

- (void)loadData;
- (void)changeValueForType:(ZZSecretSwitchCellType)type;
- (void)buttonSelectedWithType:(ZZSecretButtonCellType)type;

@end


@protocol ZZSecretInteractorOutput <NSObject>

- (void)dataLoaded:(ZZSettingsModel *)model;

@end