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

+ (void)updateMessageWithID:(NSString *)messageID setStatus:(ZZMessageStatus)status
{
    [self _updateMessageWithID:messageID usingBlock:^(TBMMessage *messageEntity) {
        messageEntity.statusValue = status;
    }];
}

+ (void)_updateMessageWithID:(NSString *)messageID usingBlock:(void (^)(TBMMessage *messageEntity))updateBlock
{
    ANDispatchBlockToMainQueue(^{
        TBMMessage *messageEntity = [self entityWithID:messageID createIfNeeded:NO];
        
        if (!messageEntity) {
            return;
        }
        
        updateBlock(messageEntity);
        [messageEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
}

+ (void)deleteReadMessagesForFriendWithID:(NSString *)friendID
{
        ZZLogInfo(@"deleteAllViewedMessages friendID: %@", friendID);
                
        ANDispatchBlockToMainQueue(^{
            
            NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"friend.idTbm = %@", friendID];
            NSPredicate *statusPredicate = [NSPredicate predicateWithFormat:@"status = %d", ZZMessageStatusRead];
            NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[friendPredicate, statusPredicate]];
                
            [TBMMessage MR_deleteAllMatchingPredicate:predicate];
        });
}

@end
