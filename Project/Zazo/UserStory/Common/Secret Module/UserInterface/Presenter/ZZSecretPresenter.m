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

- (void)dataLoaded:(ZZDebugSettingsStateDomainModel *)model;
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
        case ZZSecretScreenActionsTypeResetTutorialHints:
        {
            [self.interactor resetHints];
        } break;
        case ZZSecretScreenActionsTypeFeatureOptions:
        {
//            [self.interactor featu] // TODO: check Maxim code
        } break;
        case ZZSecretScreenActionsTypeEnableAllFeatures:
        {
            [self.interactor updateAllFeaturesToEnabled];
        } break;
        case ZZSecretScreenActionsTypeDispatchMessage:
        {
            [self.interactor dispatchData];
        } break;
        case ZZSecretScreenActionsTypeClearUserData:
        {
            [self.interactor removeAllUserData];
        } break;
        case ZZSecretScreenActionsTypeDeleteAllDanglingFiles:
        {
            [self.interactor removeAllDanglingFiles];
        } break;
        case ZZSecretScreenActionsTypeCrashApplication:
        {
            [self.interactor forceCrash];
        } break;
        case ZZSecretScreenActionsTypeLogsScreen:
        {
            [self.wireframe presentLogsController];
        } break;
        case ZZSecretScreenActionsTypeStateScreen:
        {
            [self.wireframe presentStateController];
        } break;
        case ZZSecretScreenActionsTypeDebugUIScreen:
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

- (void)updateShouldUseSDKToLoggingTypeValueTo:(BOOL)value
{
    [self.interactor updateShouldUserSDKForLogging:value];
}

- (void)updateServerEndpointTypeValueTo:(NSInteger)value
{
    [self.tableDataSource updateEnabledCustomTextFieldStateTo:(value == 2)];
    [self.interactor updateServerStateTo:value];
}

- (void)updateCustomServerURLValueTo:(NSString*)value
{
    [self.interactor updateCustomServerEnpointValueTo:value];
}

- (void)updatePushNotificationState:(BOOL)state
{
    [self.interactor updatePushNotificationStateTo:state];
}

@end
