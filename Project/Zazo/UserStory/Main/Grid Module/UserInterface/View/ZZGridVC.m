//
//  ZZGridVC.m
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridVC.h"
#import "ZZGridView.h"
#import "ZZGridCollectionController.h"
#import "ZZGridDataSource.h"

@interface ZZGridVC () <ZZGridCollectionControllerDelegate>


@property (nonatomic, strong) ZZGridView* gridView;
@property (nonatomic, strong) ZZGridCollectionController* controller;

@end

@implementation ZZGridVC

- (instancetype)init
{
    if (self = [super init])
    {   
        self.gridView = [ZZGridView new];
        self.controller = [[ZZGridCollectionController alloc] initWithCollectionView:self.gridView.collectionView];
        self.controller.delegate = self;
        
        @weakify(self);
        [[self.gridView.menuButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
          @strongify(self);
            [self.eventHandler presentMenu];
        }];
    }
    return self;
}

- (void)loadView
{
    self.view = self.gridView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)udpateWithDataSource:(ZZGridDataSource *)dataSource
{
    self.controller.storage = dataSource.storage;
}

#pragma mark - Controller Delegate Method

- (void)selectedViewWithIndexPath:(NSIndexPath *)indexPath
{
    [self.eventHandler selectedCollectionViewWithIndexPath:indexPath];
}

- (id)cellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.gridView.collectionView cellForItemAtIndexPath:indexPath];
}

@end
