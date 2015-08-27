//
//  ZZFriendDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDataProvider.h"
#import "TBMFriend.h"
#import "MagicalRecord.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendModelsMapper.h"

@implementation ZZFriendDataProvider


#pragma mark - Load

+ (NSArray*)loadAllFriends
{
    NSArray* result = [TBMFriend MR_findAllInContext:[self _context]];
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (ZZFriendDomainModel*)friendWithOutgoingVideoItemID:(NSString*)videoItemID
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.outgoingVideoId value:videoItemID];
}

+ (ZZFriendDomainModel*)friendWithItemID:(NSString*)itemID
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.idTbm value:itemID];
}

+ (ZZFriendDomainModel*)friendWithMKeyValue:(NSString*)mKeyValue
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.mkey value:mKeyValue];
}


#pragma mark - Count

+ (NSInteger)friendsCount
{
    return [TBMFriend MR_countOfEntitiesWithContext:[self _context]];
}


#pragma mark - Mapping

+ (TBMFriend*)entityFromModel:(ZZFriendDomainModel*)model
{
    //TODO:
    return nil;
}

+ (ZZFriendDomainModel*)modelFromEntity:(TBMFriend*)entity
{
    return [ZZFriendModelsMapper fillModel:[ZZFriendDomainModel new] fromEntity:entity];
}


#pragma mark - CRUD

+ (void)upsertFriendWithModel:(ZZFriendDomainModel*)model
{
    TBMFriend* entity = [self entityFromModel:model];
    [ZZFriendModelsMapper fillEntity:entity fromModel:model];
    [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
}

+ (void)deleteFriendWithID:(NSString*)itemID
{
    TBMFriend* entity = [[TBMFriend MR_findByAttribute:TBMFriendAttributes.idTbm withValue:itemID inContext:[self _context]] firstObject];
    [entity MR_deleteEntityInContext:[self _context]];
    [[self _context] MR_saveToPersistentStoreAndWait];
}


#pragma mark - Private

+ (ZZFriendDomainModel*)_findFirstWithAttribute:(NSString*)attribute value:(NSString*)value
{
    NSArray* result = [TBMFriend MR_findByAttribute:attribute withValue:value inContext:[self _context]];
    TBMFriend* entity = [result firstObject];
    return [self modelFromEntity:entity];
}

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_context];
}


//+ (NSUInteger)allUnviewedCount { // TODO:
//    NSUInteger result = 0;
//    for (TBMFriend *friend in [self all]) {
//        result += friend.unviewedCount;
//    }
//    return result;
//}

//
//+ (instancetype)findWithMatchingPhoneNumber:(NSString *)phone{
//    for (TBMFriend *f in [TBMFriend all]){
//        if ([TBMPhoneUtils isNumberMatch:phone secondNumber:f.mobileNumber])
//            return f;
//    }
//    return nil;
//}



//// TODO: GARF! This method will block forever if it is called from the uiThread. Make sure to fix this problem.
//+ (void)createOrUpdateWithServerParams:(NSDictionary *)params complete:(void (^)(TBMFriend *friend))complete{
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        BOOL servHasApp = [TBMHttpManager hasAppWithServerValue: [params objectForKey:SERVER_PARAMS_FRIEND_HAS_APP_KEY]];
//        TBMFriend *f = [TBMFriend findWithMkey:[params objectForKey:SERVER_PARAMS_FRIEND_MKEY_KEY]];
//        if (f != nil){
//            // OB_INFO(@"createWithServerParams: friend already exists.");
//            if (f.hasApp ^ servHasApp){
//                OB_INFO(@"createWithServerParams: Friend exists updating hasApp only since it is different.");
//                f.hasApp = servHasApp;
//                [f notifyVideoStatusChange];
//            }
//            if (complete != nil)
//                complete(f);
//            return;
//        }
//        
//        __block TBMFriend *friend;
//        [[TBMFriend managedObjectContext] performBlockAndWait:^{
//            friend = (TBMFriend *)[[NSManagedObject alloc]
//                                   initWithEntity:[TBMFriend entityDescription]
//                                   insertIntoManagedObjectContext:[TBMFriend managedObjectContext]];
//            
//            friend.firstName = [params objectForKey:SERVER_PARAMS_FRIEND_FIRST_NAME_KEY];
//            friend.lastName = [params objectForKey:SERVER_PARAMS_FRIEND_LAST_NAME_KEY];
//            friend.mobileNumber = [params objectForKey:SERVER_PARAMS_FRIEND_MOBILE_NUMBER_KEY];
//            friend.idTbm = [params objectForKey:SERVER_PARAMS_FRIEND_ID_KEY];
//            friend.mkey = [params objectForKey:SERVER_PARAMS_FRIEND_MKEY_KEY];
//            friend.ckey = [params objectForKey:SERVER_PARAMS_FRIEND_CKEY_KEY];
//            friend.timeOfLastAction = [NSDate date];
//            friend.hasApp = servHasApp;
//        }];
//        OB_INFO(@"Added friend: %@", friend.firstName);
//        [friend notifyVideoStatusChange];
//        if (complete != nil)
//            complete(friend);
//    });
//}


@end
