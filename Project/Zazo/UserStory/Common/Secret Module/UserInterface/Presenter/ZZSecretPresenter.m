//
//  ZZSecretPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretPresenter.h"
#import "ZZSecretDataSource.h"

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
    [self.interactor loadData];
}

#pragma mark - Output

- (void)dataLoaded:(ZZDomainModel *)model
{
    [self.tableDataSource setupStorageWithModels:[self _convertToViewModels:model.list]]
}

- (NSArray *)_convertToViewModels:(NSArray *)models
{
    return [[models.rac_sequence map:^id(id value) {
        
        ZZCellViewModel* viewModel = [ZZCellViewModel new];
        viewModel.item = value;
        return viewModel;
        
    }] array];
}

#pragma mark - Module Interface

- (void)backSelected
{
    [self.wireframe dismissSecretController];
}


@end
