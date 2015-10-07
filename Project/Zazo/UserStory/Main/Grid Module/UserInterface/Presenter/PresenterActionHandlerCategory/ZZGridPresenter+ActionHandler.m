//
//  ZZGridPresenter+ActionHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridPresenter+ActionHandler.h"
#import "ZZGridPresenterInterface.h"
#import "ZZGridDataSource.h"
#import "ZZGridActionHandler.h"

@implementation ZZGridPresenter (ActionHandler)


- (void)_handleEvent:(ZZGridActionEventType)event withDomainModel:(ZZGridDomainModel*)model
{
    NSInteger index = [[self dataSource] indexForUpdatedDomainModel:model];
    [[self actionHandler] handleEvent:event withIndex:index];
}

- (void)_handleInviteEvent
{
    CGFloat delayAfterViewDownloaded = 2.0f;
    ANDispatchBlockAfter(delayAfterViewDownloaded, ^{
        if ([[self dataSource] frindsOnGridNumber] == 0)
        {
            NSInteger indexForInviteEvent = 5;
            [[self actionHandler] handleEvent:ZZGridActionEventTypeDontHaveFriends withIndex:indexForInviteEvent];
        }
    });
}

- (void)_handleRecordEventWithCellViewModel:(ZZGridCellViewModel*)cellViewModel
{
    
}

@end
