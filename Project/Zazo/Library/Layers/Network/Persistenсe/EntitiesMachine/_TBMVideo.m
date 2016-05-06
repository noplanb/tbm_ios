//
//  "_TBMVideo.m"
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMVideo.m instead.

#import "_TBMVideo.h"

const struct TBMVideoAttributes TBMVideoAttributes = {
    .downloadRetryCount = @"downloadRetryCount",
    .status = @"status",
    .videoId = @"videoId",
};

const struct TBMVideoRelationships TBMVideoRelationships = {
    .friend = @"friend",
};

@implementation TBMVideoID
@end

@implementation _TBMVideo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc_
{
    NSParameterAssert(moc_);
    return [NSEntityDescription insertNewObjectForEntityForName:@"TBMVideo" inManagedObjectContext:moc_];
}

+ (NSString *)entityName
{
    return @"TBMVideo";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc_
{
    NSParameterAssert(moc_);
    return [NSEntityDescription entityForName:@"TBMVideo" inManagedObjectContext:moc_];
}

- (TBMVideoID *)objectID
{
    return (TBMVideoID *)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

    if ([key isEqualToString:@"downloadRetryCountValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"downloadRetryCount"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }
    if ([key isEqualToString:@"statusValue"])
    {
        NSSet *affectingKey = [NSSet setWithObject:@"status"];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
        return keyPaths;
    }

    return keyPaths;
}

@dynamic downloadRetryCount;

- (int32_t)downloadRetryCountValue
{
    NSNumber *result = [self downloadRetryCount];
    return [result intValue];
}

- (void)setDownloadRetryCountValue:(int32_t)value_
{
    [self setDownloadRetryCount:@(value_)];
}

- (int32_t)primitiveDownloadRetryCountValue
{
    NSNumber *result = [self primitiveDownloadRetryCount];
    return [result intValue];
}

- (void)setPrimitiveDownloadRetryCountValue:(int32_t)value_
{
    [self setPrimitiveDownloadRetryCount:@(value_)];
}

@dynamic status;

- (int32_t)statusValue
{
    NSNumber *result = [self status];
    return [result intValue];
}

- (void)setStatusValue:(int32_t)value_
{
    [self setStatus:@(value_)];
}

- (int32_t)primitiveStatusValue
{
    NSNumber *result = [self primitiveStatus];
    return [result intValue];
}

- (void)setPrimitiveStatusValue:(int32_t)value_
{
    [self setPrimitiveStatus:@(value_)];
}

@dynamic videoId;

@dynamic friend;

@end

