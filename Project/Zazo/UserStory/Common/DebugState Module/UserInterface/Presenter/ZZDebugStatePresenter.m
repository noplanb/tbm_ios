//
//  ZZDebugStatePresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDebugStatePresenter.h"
#import "ZZDebugStateDataSource.h"

@interface ZZDebugStatePresenter ()

@property (nonatomic, strong) ZZDebugStateDataSource* dataSource;

@end

@implementation ZZDebugStatePresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZDebugStateViewInterface>*)userInterface
{
    self.dataSource = [ZZDebugStateDataSource new];
    self.userInterface = userInterface;
    [self.userInterface updateDataSource:self.dataSource];
    
    [self.interactor loadData];
}


#pragma mark - Output

- (void)dataLoadedWithAllVideos:(NSArray *)allVideos incomeDandling:(NSArray *)incomeDandling outcomeDandling:(NSArray *)outcome
{
    [self.dataSource setupWithAllVideos:allVideos incomeDandling:incomeDandling outcomeDandling:outcome];
}


#pragma mark - Module Interface



@end
