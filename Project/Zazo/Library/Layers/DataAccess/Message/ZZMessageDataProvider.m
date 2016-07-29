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

+ (NSArray <ZZMessageDomainModel *> *)messagesOfFriendWithID:(NSString *)friendID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friend.idTbm = %@", friendID];
        NSArray *entities = [TBMMessage MR_findAllWithPredicate:predicate];
        
        NSArray *models =[ entities.rac_sequence map:^id(TBMMessage *messageEntity) {
            return [self modelFromEntity:messageEntity];
        }].array;
        
        return models;
    });
}

+ (ZZMessageDomainModel *)modelFromEntity:(TBMMessage *)messageEntity
{
    ZZMessageDomainModel *messageModel = [ZZMessageDomainModel new];
    [ZZMessageDataMapper fillModel:messageModel fromEntity:messageEntity];
    return  messageModel;
}

@end
