//
//  ZZSecretPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretPresenter.h"
#import "ZZSecretDataSource.h"

@interface ZZSecretPresenter ()<ZZSecretDataSourceDelegate>

@property (nonatomic, strong) ZZSecretDataSource* tableDataSource;

@end

@implementation ZZSecretPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.tableDataSource = [ZZSecretDataSource new];
        self.tableDataSource.delegate = self;
    }
    return self;
}

- (void)configurePresenterWithUserInterface:(UIViewController<ZZSecretViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.userInterface updateDataSource:self.tableDataSource];
    
    [self.interactor loadData];
}

#pragma mark - Output

- (void)dataLoaded:(ZZSettingsModel *)model;
{
    [self.tableDataSource setupStorageWithViewModel:model];
}

- (void)serverEndpointValueUpdatedTo:(NSString *)value
{
    [self.tableDataSource updateServerCustomURLValue:value];
}

#pragma mark - Module Interface

- (void)dismissController
{
    [self.wireframe dismissSecretController];
}

#pragma mark - ZZSecretDataSourceDelegate

- (void)actionWithType:(ZZSecrectScreenActionsType)type
{
    //TODO: show message that action done
    switch (type)
    {
        case ZZSecrectScreenActionsTypeResetTutorialHints:
        {
            [self.interactor resetHints];
        } break;
        case ZZSecrectScreenActionsTypeFeatureOptions:
        {
//            [self.interactor featu] // TODO: check Maxim code
        } break;
        case ZZSecrectScreenActionsTypeDispatchMessage:
        {
            [self.interactor dispatchData];
        } break;
        case ZZSecrectScreenActionsTypeClearUserData:
        {
            [self.interactor removeAllUserData];
        } break;
        case ZZSecrectScreenActionsTypeDeleteAllDanglingFiles:
        {
            [self.interactor removeAllDanglingFiles];
        } break;
        case ZZSecrectScreenActionsTypeCrashApplication:
        {
            [self.interactor forceCrash];
        } break;
        case ZZSecrectScreenActionsTypeLogsScreen:
        {
            [self.wireframe presentLogsController];
        } break;
        case ZZSecrectScreenActionsTypeStateScreen:
        {
            [self.wireframe presentStateController];
        } break;
        case ZZSecrectScreenActionsTypeDebugUIScreen:
        {
            [self.wireframe presentDebugController];
        } break;
            
        default: break;
    }
}

- (void)updateDebugModeValueTo:(BOOL)isEnabled
{
    [self.interactor updateDebugStateTo:isEnabled];
}

- (void)updateShouldForceSMSValueTo:(BOOL)isEnabled
{
    [self.interactor updateShouldForceSMSStateTo:isEnabled];
}

- (void)updateShouldForceCallValueTo:(BOOL)isEnabled
{
    [self.interactor updateShouldForceCallStateTo:isEnabled];
}

- (void)updateEnabledAllFeaturesValueTo:(BOOL)isEnabled
{
    //TODO: check Maxim code
}

- (void)updateShouldUseSDKToLoggingTypeValueTo:(BOOL)value
{
    [self.interactor updateShouldUserSDKForLogging:value];
}

- (void)updateServerEndpointTypeValueTo:(NSInteger)value
{
    [self.interactor updateServerStateTo:value];
}

- (void)updateCustomServerURLValueTo:(NSString*)value
{
    [self.interactor updateCustomServerEnpointValueTo:value];
}

@end
