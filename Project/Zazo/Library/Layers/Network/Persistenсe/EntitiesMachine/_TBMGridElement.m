//
//  "_TBMGridElement.m"
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMGridElement.m instead.

#import "_TBMGridElement.h"

const struct TBMGridElementAttributes TBMGridElementAttributes = {
    .index = @"index",
};

const struct TBMGridElementRelationships TBMGridElementRelationships = {
    .friend = @"friend",
};

@implementation TBMGridElementID
@end

@implementation _TBMGridElement

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc_
{
    NSParameterAssert(moc_);
    return [NSEntityDescription insertNewObjectForEntityForName:@"TBMGridElement" inManagedObjectContext:moc_];
}

+ (NSString *)entityName
{
    return @"TBMGridElement";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc_
{
    NSParameterAssert(moc_);
    return [NSEntityDescription entityForName:@"TBMGridElement" inManagedObjectContext:moc_];
}

- (TBMGridElementID *)objectID
{
    return (TBMGridElementID *)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

    if ([key isEqualToString:@"indexValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"index"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }

    return keyPaths;
}

@dynamic index;

- (int32_t)indexValue
{
    NSNumber *result = [self index];
    return [result intValue];
}

- (void)setIndexValue:(int32_t)value_
{
    [self setIndex:@(value_)];
}

- (int32_t)primitiveIndexValue
{
    NSNumber *result = [self primitiveIndex];
    return [result intValue];
}

- (void)setPrimitiveIndexValue:(int32_t)value_
{
    [self setPrimitiveIndex:@(value_)];
}

@dynamic friend;

@end

