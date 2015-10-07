//
//  ZZGridInteractor+ActionHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridInteractor+ActionHandler.h"
#import "ZZFriendDomainModel.h"
#import "TBMFriend.h"


@implementation ZZGridInteractor (ActionHandler)

- (void)_handleModel:(ZZGridDomainModel*)model
{
    
        if (model.relatedUser.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE &&
            model.relatedUser.lastIncomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADED &&
            [self.output friendsNumberOnGrid] == 0)
        {
            [self.output handleModel:model withEvent:ZZGridActionEventTypeBecomeMessage];
        }
}

@end
