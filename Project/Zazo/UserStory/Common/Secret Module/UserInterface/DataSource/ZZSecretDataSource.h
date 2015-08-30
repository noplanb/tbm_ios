//
//  ZZSecretDataSource.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretEnums.h"

@class ANMemoryStorage;
@class ZZSettingsViewModel;

typedef NS_ENUM(NSInteger, ZZSecretSection)
{
    ZZSecretSectionGeneral,
    ZZSecretSectionDebugOptions,
    ZZSecretSectionCustomization,
    ZZSecretSectionRegistrationOptions,
    ZZSecretSectionTutorial
};

@protocol ZZSecretDataSourceDelegate <NSObject>

- (void)buttonSelectedWithType:(ZZSecretButtonCellType)type;
- (void)switchValueChangedForType:(ZZSecretSwitchCellType)type;

@end

@interface ZZSecretDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;
@property (nonatomic, weak) id<ZZSecretDataSourceDelegate> delegate;

- (void)setupStorageWithViewModel:(ZZSettingsViewModel *)model;

@end
