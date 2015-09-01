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
@class ZZSettingsModel;

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
    
    ZZSecrectScreenActionsTypeDispatchMessage,
    
    ZZSecrectScreenActionsTypeClearUserData,
    ZZSecrectScreenActionsTypeDeleteAllDanglingFiles,
    ZZSecrectScreenActionsTypeCrashApplication
};

@protocol ZZSecretDataSourceDelegate <NSObject>

- (void)actionWithType:(ZZSecrectScreenActionsType)type;

- (void)updateDebugModeValueTo:(BOOL)isEnabled;
- (void)updateShouldForceSMSValueTo:(BOOL)isEnabled;
- (void)updateShouldForceCallValueTo:(BOOL)isEnabled;

- (void)updateEnabledAllFeaturesValueTo:(BOOL)isEnabled;

- (void)updateShouldUseSDKToLoggingTypeValueTo:(BOOL)value;

- (void)updateServerEndpointTypeValueTo:(NSInteger)value;
- (void)updateCustomServerURLValueTo:(NSString*)value;


@end

@interface ZZSecretDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;
@property (nonatomic, weak) id<ZZSecretDataSourceDelegate> delegate;

- (void)setupStorageWithViewModel:(ZZSettingsModel*)model;
- (void)updateServerCustomURLValue:(NSString*)value;

- (void)itemSelectedAtIndexPath:(NSIndexPath*)indexPath;

- (void)updateEnabledCustomTextFieldStateTo:(BOOL)isEnabled;

@end
