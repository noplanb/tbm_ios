//
//  ZZSecretDataSource.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretSwitchCell.h"
#import "ZZSecretSegmentCell.h"
#import "ZZSecretScreenTextEditCell.h"

@class ANMemoryStorage;
@class ZZDebugSettingsStateDomainModel;

typedef NS_ENUM(NSInteger, ZZSecretSection)
{
    ZZSecretSectionUserInfo,
    ZZSecretSectionDetailScreens,
    ZZSecretSectionDebugOptions,
    ZZSecretSectionCustomAppModes,
    ZZSecretSectionTutorial,
    ZZSecretSectionServerOptions,
    ZZSecretSectionLoggingOptions,
    ZZSecretSectionResetData
};

typedef NS_ENUM(NSInteger, ZZSecrectScreenActionsType)
{
    ZZSecrectScreenActionsTypeLogsScreen,
    ZZSecrectScreenActionsTypeStateScreen,
    ZZSecrectScreenActionsTypeDebugUIScreen,
    
    ZZSecrectScreenActionsTypeResetTutorialHints,
    ZZSecrectScreenActionsTypeFeatureOptions,
    ZZSecretScreenActionsTypeEnableAllFeatures,
    
    ZZSecrectScreenActionsTypeDispatchMessage,
    
    ZZSecrectScreenActionsTypeClearUserData,
    ZZSecrectScreenActionsTypeDeleteAllDanglingFiles,
    ZZSecrectScreenActionsTypeCrashApplication
};

@protocol ZZSecretDataSourceDelegate <NSObject>

- (void)actionWithType:(ZZSecrectScreenActionsType)type;

- (void)updateDebugModeValueTo:(BOOL)isEnabled;

- (void)updateShouldUseSDKToLoggingTypeValueTo:(BOOL)value;

- (void)updateServerEndpointTypeValueTo:(NSInteger)value;
- (void)updateCustomServerURLValueTo:(NSString*)value;
- (void)updatePushNotificationState:(BOOL)state;

@end

@interface ZZSecretDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;
@property (nonatomic, weak) id<ZZSecretDataSourceDelegate> delegate;

- (void)setupStorageWithViewModel:(ZZDebugSettingsStateDomainModel*)model;
- (void)updateServerCustomURLValue:(NSString*)value;

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath;

- (void)updateEnabledCustomTextFieldStateTo:(BOOL)isEnabled;

@end
