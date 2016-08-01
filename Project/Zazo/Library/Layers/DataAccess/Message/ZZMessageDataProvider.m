//
//  ZZMessageDataProvider.m
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZMessageDataProvider+Entities.h"
#import "ZZMessageDataMapper.h"

@import MagicalRecord;

@implementation ZZMessageDataProvider

+ (ZZMessageDomainModel *)modelWithID:(NSString *)messageID
{
    return ZZDispatchOnMainThreadAndReturn(^id {
        TBMMessage *messageEntity = [self entityWithID:messageID];
        
        if (!messageEntity) {
            return nil;
        }
        
        return [self modelFromEntity:messageEntity];
    });

}

+ (TBMMessage *)entityWithID:(NSString *)messageID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID = %@", messageID];
    return [TBMMessage MR_findFirstWithPredicate:predicate];
    
}

+ (BOOL)messageExists:(NSString *)messageID
{
    return [ZZDispatchOnMainThreadAndReturn(^id{
        
        BOOL exists = [self entityWithID:messageID] != nil;
        return @(exists);
        
    }) boolValue];
}

+ (NSArray <ZZMessageDomainModel *> *)messagesOfFriendWithID:(NSString *)friendID newOnly:(BOOL)flag
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        NSPredicate *predicate = [self _predicateForFriendID:friendID newMessagesOnly:flag];
        NSArray *entities = [TBMMessage MR_findAllSortedBy:@"messageID" ascending:YES withPredicate:predicate];        
        
        NSArray *models =[ entities.rac_sequence map:^id(TBMMessage *messageEntity) {
            return [self modelFromEntity:messageEntity];
        }].array;
        
        return models;
    });
}

+ (NSUInteger)newMessageCountOfFriendWithID:(NSString *)friendID
{
    return [ZZDispatchOnMainThreadAndReturn(^id{
        return @([TBMMessage MR_countOfEntitiesWithPredicate:[self _predicateForFriendID:friendID newMessagesOnly:YES]]);
    }) unsignedIntegerValue];
}


+ (NSPredicate *)_predicateForFriendID:(NSString *)friendID newMessagesOnly:(BOOL)flag
{
    NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"friend.idTbm = %@", friendID];
    
    if (!flag) {
        return friendPredicate;
    }
    
    NSPredicate *statusPredicate = [NSPredicate predicateWithFormat:@"status = %d", ZZMessageStatusNew];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[friendPredicate, statusPredicate]];
    
    return predicate;

}

+ (ZZMessageDomainModel *)modelFromEntity:(TBMMessage *)messageEntity
{
    ZZMessageDomainModel *messageModel = [ZZMessageDomainModel new];
    [ZZMessageDataMapper fillModel:messageModel fromEntity:messageEntity];
    return  messageModel;
}

@end
