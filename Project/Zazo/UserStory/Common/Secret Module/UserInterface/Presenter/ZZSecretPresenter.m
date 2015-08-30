//
//  ZZSecretPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretPresenter.h"
#import "ZZSecretDataSource.h"
#import "ZZSettingsViewModel.h"

@interface ZZSecretPresenter () <ZZSecretDataSourceDelegate>

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
    ZZSettingsViewModel *settingsViewModel = [ZZSettingsViewModel new];
    settingsViewModel.item = model;
    
    [self.tableDataSource setupStorageWithViewModel:settingsViewModel];
}

#pragma mark - Module Interface

- (void)backSelected
{
    [self.wireframe dismissSecretController];
}

#pragma mark - ZZSecretDataSourceDelegate

- (void)buttonSelectedWithType:(ZZSecretButtonCellType)type
{
    [self.interactor buttonSelectedWithType:type];
}

- (void)switchValueChangedForType:(ZZSecretSwitchCellType)type
{
    [self.interactor changeValueForType:type];
}


@end
