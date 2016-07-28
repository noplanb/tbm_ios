//
//  _TBMMessage.h
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMMessage.h instead.

extern const struct TBMMessageAttributes {
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *type;
} TBMMessageAttributes;

extern const struct TBMMessageRelationships {
	__unsafe_unretained NSString *friend;
} TBMMessageRelationships;

@class TBMFriend;

@interface TBMMessageID : NSManagedObjectID {}
@end

@interface _TBMMessage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TBMMessageID* objectID;

@property (nonatomic, strong) NSString* body;

//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* type;

@property (atomic) int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) TBMFriend *friend;

//- (BOOL)validateFriend:(id*)value_ error:(NSError**)error_;

@end

@interface _TBMMessage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (TBMFriend*)primitiveFriend;
- (void)setPrimitiveFriend:(TBMFriend*)value;

@end
