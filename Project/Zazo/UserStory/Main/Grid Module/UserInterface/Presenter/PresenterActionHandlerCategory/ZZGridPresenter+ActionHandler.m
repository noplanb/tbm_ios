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
    ANDispatchBlockToMainQueue(^{
        NSInteger index = [[self dataSource] indexForUpdatedDomainModel:model];
        if (index != NSNotFound)
        {
            [[self actionHandler] handleEvent:event withIndex:index friendModel:model.relatedUser];
        }
    });
}

- (void)_handleInviteEvent
{
    ANDispatchBlockToMainQueue(^{
        CGFloat delayAfterViewDownloaded = 1.2f;
        ANDispatchBlockAfter(delayAfterViewDownloaded, ^{
            if ([[self dataSource] friendsOnGridNumber] == 0)
            {
                NSInteger indexForInviteEvent = 5;
                [[self actionHandler] handleEvent:ZZGridActionEventTypeDontHaveFriends withIndex:indexForInviteEvent friendModel:nil];
            }
        });
    });
}

- (void)_handleRecordHintWithCellViewModel:(ZZFriendDomainModel*)model
{
    ANDispatchBlockToMainQueue(^{
        NSInteger index = [[self dataSource] indexForFriendDomainModel:model];
        if (index != NSNotFound)
        {
            [[self actionHandler] handleEvent:ZZGridActionEventTypeMessageDidPlayed withIndex:index friendModel:model];
        }
    });
}

- (void)_handleSentMessageEventWithCellViewModel:(ZZGridCellViewModel*)cellViewModel
{
    ANDispatchBlockToMainQueue(^{

            CGFloat delayAfterUploadAnimationStopped = 0.5f;
            ANDispatchBlockAfter(delayAfterUploadAnimationStopped, ^{
                NSInteger index = [[self dataSource] indexForViewModel:cellViewModel];
                if (index != NSNotFound)
                {
                    [[self actionHandler] handleEvent:ZZGridActionEventTypeMessageDidSent withIndex:index friendModel:cellViewModel.item.relatedUser];
                }
            });
    });
}

- (void)_handleSentWelcomeHintWithFriendDomainModel:(ZZFriendDomainModel*)model
{
    ANDispatchBlockToMainQueue(^{
        
        NSInteger index = [self indexOnGridViewForFriendModel:model];
        if (index != NSNotFound)
        {
            [[self actionHandler] handleEvent:ZZGridActionEventTypeFriendDidInvited withIndex:index friendModel:model];
            [self showFriendAnimationWithFriend:model];
        }
    });
}

@end
