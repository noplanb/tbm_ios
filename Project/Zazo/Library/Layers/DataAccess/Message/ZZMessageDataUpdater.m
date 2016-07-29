//
//  ZZMessageDataUpdater.m
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZMessageDataUpdater+Entities.h"
#import "ZZMessageDataProvider+Entities.h"
#import "ZZMessageDataMapper.h"

@import MagicalRecord;

@implementation ZZMessageDataUpdater

+ (void)insertMessage:(ZZMessageDomainModel *)messageModel
{
    
    ANDispatchBlockToMainQueue(^{
        
        if ([ZZMessageDataProvider messageExists:messageModel.messageID]) {
            ZZLogError(@"insertMessage messageExists: %@", messageModel.messageID);
        }
        
        TBMMessage *messageEntity = [self entityWithID:messageModel.messageID createIfNeeded:YES];
        [ZZMessageDataMapper fillEntity:messageEntity fromModel:messageModel];
        [messageEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
}

+ (TBMMessage *)entityWithID:(NSString *)messageID createIfNeeded:(BOOL)flag
{
    TBMMessage *messageEntity = [ZZMessageDataProvider entityWithID:messageID];
    
    if (messageEntity)
    {
        return messageEntity;
    }
    
    if (!flag)
    {
        return nil;
    }
    
    messageEntity = [TBMMessage MR_createEntity];
    messageEntity.messageID = messageID;
    
    return messageEntity;
}

//+ (void)updateMessageWithID:(NSString *)messageID setBody:(NSString *)body
//{
//    
//}
//
//+ (void)updateMessageWithID:(NSString *)messageID setType:(NSString *)messageID
//{
//    
//}
//
//+ (void)updateMessageWithID:(NSString *)messageID setFriendID:(NSString *)friendID
//{
//    
//}

@end
