//
//  "_TBMFriend.m"
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMFriend.m instead.

#import "_TBMFriend.h"

const struct TBMFriendAttributes TBMFriendAttributes = {
        .cid = @"cid",
        .ckey = @"ckey",
        .everSent = @"everSent",
        .firstName = @"firstName",
        .friendshipCreatorMKey = @"friendshipCreatorMKey",
        .friendshipStatus = @"friendshipStatus",
        .hasApp = @"hasApp",
        .idTbm = @"idTbm",
        .isFriendshipCreator = @"isFriendshipCreator",
        .lastIncomingVideoStatus = @"lastIncomingVideoStatus",
        .lastName = @"lastName",
        .lastVideoStatusEventType = @"lastVideoStatusEventType",
        .mkey = @"mkey",
        .mobileNumber = @"mobileNumber",
        .outgoingVideoId = @"outgoingVideoId",
        .outgoingVideoStatus = @"outgoingVideoStatus",
        .timeOfLastAction = @"timeOfLastAction",
        .uploadRetryCount = @"uploadRetryCount",
};

const struct TBMFriendRelationships TBMFriendRelationships = {
        .gridElement = @"gridElement",
        .videos = @"videos",
};

@implementation TBMFriendID
@end

@implementation _TBMFriend

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc_
{
    NSParameterAssert(moc_);
    return [NSEntityDescription insertNewObjectForEntityForName:@"TBMFriend" inManagedObjectContext:moc_];
}

+ (NSString *)entityName
{
    return @"TBMFriend";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc_
{
    NSParameterAssert(moc_);
    return [NSEntityDescription entityForName:@"TBMFriend" inManagedObjectContext:moc_];
}

- (TBMFriendID *)objectID
{
    return (TBMFriendID *)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

    if ([key isEqualToString:@"cidValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"cid"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }
    if ([key isEqualToString:@"everSentValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"everSent"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }
    if ([key isEqualToString:@"hasAppValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"hasApp"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }
    if ([key isEqualToString:@"isFriendshipCreatorValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"isFriendshipCreator"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }
    if ([key isEqualToString:@"lastIncomingVideoStatusValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"lastIncomingVideoStatus"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }
    if ([key isEqualToString:@"lastVideoStatusEventTypeValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"lastVideoStatusEventType"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }
    if ([key isEqualToString:@"outgoingVideoStatusValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"outgoingVideoStatus"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }
    if ([key isEqualToString:@"uploadRetryCountValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"uploadRetryCount"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }

    return keyPaths;
}

@dynamic cid;

- (int32_t)cidValue
{
    NSNumber *result = [self cid];
    return [result intValue];
}

- (void)setCidValue:(int32_t)value_
{
    [self setCid:@(value_)];
}

- (int32_t)primitiveCidValue
{
    NSNumber *result = [self primitiveCid];
    return [result intValue];
}

- (void)setPrimitiveCidValue:(int32_t)value_
{
    [self setPrimitiveCid:@(value_)];
}

@dynamic ckey;

@dynamic everSent;

- (BOOL)everSentValue
{
    NSNumber *result = [self everSent];
    return [result boolValue];
}

- (void)setEverSentValue:(BOOL)value_
{
    [self setEverSent:@(value_)];
}

- (BOOL)primitiveEverSentValue
{
    NSNumber *result = [self primitiveEverSent];
    return [result boolValue];
}

- (void)setPrimitiveEverSentValue:(BOOL)value_
{
    [self setPrimitiveEverSent:@(value_)];
}

@dynamic firstName;

@dynamic friendshipCreatorMKey;

@dynamic friendshipStatus;

@dynamic hasApp;

- (BOOL)hasAppValue
{
    NSNumber *result = [self hasApp];
    return [result boolValue];
}

- (void)setHasAppValue:(BOOL)value_
{
    [self setHasApp:@(value_)];
}

- (BOOL)primitiveHasAppValue
{
    NSNumber *result = [self primitiveHasApp];
    return [result boolValue];
}

- (void)setPrimitiveHasAppValue:(BOOL)value_
{
    [self setPrimitiveHasApp:@(value_)];
}

@dynamic idTbm;

@dynamic isFriendshipCreator;

- (BOOL)isFriendshipCreatorValue
{
    NSNumber *result = [self isFriendshipCreator];
    return [result boolValue];
}

- (void)setIsFriendshipCreatorValue:(BOOL)value_
{
    [self setIsFriendshipCreator:@(value_)];
}

- (BOOL)primitiveIsFriendshipCreatorValue
{
    NSNumber *result = [self primitiveIsFriendshipCreator];
    return [result boolValue];
}

- (void)setPrimitiveIsFriendshipCreatorValue:(BOOL)value_
{
    [self setPrimitiveIsFriendshipCreator:@(value_)];
}

@dynamic lastIncomingVideoStatus;

- (int32_t)lastIncomingVideoStatusValue
{
    NSNumber *result = [self lastIncomingVideoStatus];
    return [result intValue];
}

- (void)setLastIncomingVideoStatusValue:(int32_t)value_
{
    [self setLastIncomingVideoStatus:@(value_)];
}

- (int32_t)primitiveLastIncomingVideoStatusValue
{
    NSNumber *result = [self primitiveLastIncomingVideoStatus];
    return [result intValue];
}

- (void)setPrimitiveLastIncomingVideoStatusValue:(int32_t)value_
{
    [self setPrimitiveLastIncomingVideoStatus:@(value_)];
}

@dynamic lastName;

@dynamic lastVideoStatusEventType;

- (int32_t)lastVideoStatusEventTypeValue
{
    NSNumber *result = [self lastVideoStatusEventType];
    return [result intValue];
}

- (void)setLastVideoStatusEventTypeValue:(int32_t)value_
{
    [self setLastVideoStatusEventType:@(value_)];
}

- (int32_t)primitiveLastVideoStatusEventTypeValue
{
    NSNumber *result = [self primitiveLastVideoStatusEventType];
    return [result intValue];
}

- (void)setPrimitiveLastVideoStatusEventTypeValue:(int32_t)value_
{
    [self setPrimitiveLastVideoStatusEventType:@(value_)];
}

@dynamic mkey;

@dynamic mobileNumber;

@dynamic outgoingVideoId;

@dynamic outgoingVideoStatus;

- (int32_t)outgoingVideoStatusValue
{
    NSNumber *result = [self outgoingVideoStatus];
    return [result intValue];
}

- (void)setOutgoingVideoStatusValue:(int32_t)value_
{
    [self setOutgoingVideoStatus:@(value_)];
}

- (int32_t)primitiveOutgoingVideoStatusValue
{
    NSNumber *result = [self primitiveOutgoingVideoStatus];
    return [result intValue];
}

- (void)setPrimitiveOutgoingVideoStatusValue:(int32_t)value_
{
    [self setPrimitiveOutgoingVideoStatus:@(value_)];
}

@dynamic timeOfLastAction;

@dynamic uploadRetryCount;

- (int32_t)uploadRetryCountValue
{
    NSNumber *result = [self uploadRetryCount];
    return [result intValue];
}

- (void)setUploadRetryCountValue:(int32_t)value_
{
    [self setUploadRetryCount:@(value_)];
}

- (int32_t)primitiveUploadRetryCountValue
{
    NSNumber *result = [self primitiveUploadRetryCount];
    return [result intValue];
}

- (void)setPrimitiveUploadRetryCountValue:(int32_t)value_
{
    [self setPrimitiveUploadRetryCount:@(value_)];
}

@dynamic gridElement;

@dynamic videos;

- (NSMutableSet *)videosSet
{
    [self willAccessValueForKey:@"videos"];

    NSMutableSet *result = (NSMutableSet *)[self mutableSetValueForKey:@"videos"];

    [self didAccessValueForKey:@"videos"];
    return result;
}

@end

