//
//  "_TBMMessage.m"
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMMessage.m instead.

#import "_TBMMessage.h"

const struct TBMMessageAttributes TBMMessageAttributes = {
    .body = @"body",
    .messageID = @"messageID",
    .type = @"type",
};

const struct TBMMessageRelationships TBMMessageRelationships = {
    .friend = @"friend",
};

@implementation TBMMessageID
@end

@implementation _TBMMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc_
{
    NSParameterAssert(moc_);
    return [NSEntityDescription insertNewObjectForEntityForName:@"TBMMessage" inManagedObjectContext:moc_];
}

+ (NSString *)entityName
{
    return @"TBMMessage";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc_
{
    NSParameterAssert(moc_);
    return [NSEntityDescription entityForName:@"TBMMessage" inManagedObjectContext:moc_];
}

- (TBMMessageID *)objectID
{
    return (TBMMessageID *)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

    if ([key isEqualToString:@"typeValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"type"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }

    return keyPaths;
}

@dynamic body;

@dynamic messageID;

@dynamic type;

- (int16_t)typeValue
{
    NSNumber *result = [self type];
    return [result shortValue];
}

- (void)setTypeValue:(int16_t)value_
{
    [self setType:@(value_)];
}

@dynamic friend;

@end

