//
//  _TBMGridElement.h
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMGridElement.h instead.

extern const struct TBMGridElementAttributes
{
    __unsafe_unretained NSString *index;
} TBMGridElementAttributes;

extern const struct TBMGridElementRelationships
{
    __unsafe_unretained NSString *friend;
} TBMGridElementRelationships;

@class TBMFriend;

@interface TBMGridElementID : NSManagedObjectID
{
}
@end

@interface _TBMGridElement : NSManagedObject
{
}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;

+ (NSString *)entityName;

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc_;

@property (nonatomic, readonly, strong) TBMGridElementID *objectID;

@property (nonatomic, strong) NSNumber *index;

@property (atomic) int32_t indexValue;

- (int32_t)indexValue;

- (void)setIndexValue:(int32_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) TBMFriend *friend;

//- (BOOL)validateFriend:(id*)value_ error:(NSError**)error_;

@end

@interface _TBMGridElement (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber *)primitiveIndex;

- (void)setPrimitiveIndex:(NSNumber *)value;

- (int32_t)primitiveIndexValue;

- (void)setPrimitiveIndexValue:(int32_t)value_;

- (TBMFriend *)primitiveFriend;

- (void)setPrimitiveFriend:(TBMFriend *)value;

@end
