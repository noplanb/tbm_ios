//
//  _TBMFriend.h
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMFriend.h instead.

extern const struct TBMFriendAttributes {
	__unsafe_unretained NSString *abilities;
	__unsafe_unretained NSString *avatarImage;
	__unsafe_unretained NSString *avatarTimestamp;
	__unsafe_unretained NSString *cid;
	__unsafe_unretained NSString *ckey;
	__unsafe_unretained NSString *everSent;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *friendshipCreatorMKey;
	__unsafe_unretained NSString *friendshipStatus;
	__unsafe_unretained NSString *hasApp;
	__unsafe_unretained NSString *idTbm;
	__unsafe_unretained NSString *isFriendshipCreator;
	__unsafe_unretained NSString *lastEventType;
	__unsafe_unretained NSString *lastIncomingVideoStatus;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *lastVideoStatusEventType;
	__unsafe_unretained NSString *mkey;
	__unsafe_unretained NSString *mobileNumber;
	__unsafe_unretained NSString *outgoingVideoId;
	__unsafe_unretained NSString *outgoingVideoStatus;
	__unsafe_unretained NSString *timeOfLastAction;
	__unsafe_unretained NSString *uploadRetryCount;
} TBMFriendAttributes;

extern const struct TBMFriendRelationships {
	__unsafe_unretained NSString *gridElement;
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *videos;
} TBMFriendRelationships;

@class TBMGridElement;
@class TBMMessage;
@class TBMVideo;

@interface TBMFriendID : NSManagedObjectID {}
@end

@interface _TBMFriend : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TBMFriendID* objectID;

@property (nonatomic, strong) NSNumber* abilities;

@property (atomic) int32_t abilitiesValue;
- (int32_t)abilitiesValue;
- (void)setAbilitiesValue:(int32_t)value_;

//- (BOOL)validateAbilities:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSData* avatarImage;

//- (BOOL)validateAvatarImage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* avatarTimestamp;

@property (atomic) int64_t avatarTimestampValue;
- (int64_t)avatarTimestampValue;
- (void)setAvatarTimestampValue:(int64_t)value_;

//- (BOOL)validateAvatarTimestamp:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* cid;

@property (atomic) int32_t cidValue;
- (int32_t)cidValue;
- (void)setCidValue:(int32_t)value_;

//- (BOOL)validateCid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* ckey;

//- (BOOL)validateCkey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* everSent;

@property (atomic) BOOL everSentValue;
- (BOOL)everSentValue;
- (void)setEverSentValue:(BOOL)value_;

//- (BOOL)validateEverSent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* firstName;

//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* friendshipCreatorMKey;

//- (BOOL)validateFriendshipCreatorMKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* friendshipStatus;

//- (BOOL)validateFriendshipStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* hasApp;

@property (atomic) BOOL hasAppValue;
- (BOOL)hasAppValue;
- (void)setHasAppValue:(BOOL)value_;

//- (BOOL)validateHasApp:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* idTbm;

//- (BOOL)validateIdTbm:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isFriendshipCreator;

@property (atomic) BOOL isFriendshipCreatorValue;
- (BOOL)isFriendshipCreatorValue;
- (void)setIsFriendshipCreatorValue:(BOOL)value_;

//- (BOOL)validateIsFriendshipCreator:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lastEventType;

@property (atomic) int32_t lastEventTypeValue;
- (int32_t)lastEventTypeValue;
- (void)setLastEventTypeValue:(int32_t)value_;

//- (BOOL)validateLastEventType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lastIncomingVideoStatus;

@property (atomic) int32_t lastIncomingVideoStatusValue;
- (int32_t)lastIncomingVideoStatusValue;
- (void)setLastIncomingVideoStatusValue:(int32_t)value_;

//- (BOOL)validateLastIncomingVideoStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* lastName;

//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lastVideoStatusEventType;

@property (atomic) int32_t lastVideoStatusEventTypeValue;
- (int32_t)lastVideoStatusEventTypeValue;
- (void)setLastVideoStatusEventTypeValue:(int32_t)value_;

//- (BOOL)validateLastVideoStatusEventType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mkey;

//- (BOOL)validateMkey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mobileNumber;

//- (BOOL)validateMobileNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* outgoingVideoId;

//- (BOOL)validateOutgoingVideoId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* outgoingVideoStatus;

@property (atomic) int32_t outgoingVideoStatusValue;
- (int32_t)outgoingVideoStatusValue;
- (void)setOutgoingVideoStatusValue:(int32_t)value_;

//- (BOOL)validateOutgoingVideoStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* timeOfLastAction;

//- (BOOL)validateTimeOfLastAction:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* uploadRetryCount;

@property (atomic) int32_t uploadRetryCountValue;
- (int32_t)uploadRetryCountValue;
- (void)setUploadRetryCountValue:(int32_t)value_;

//- (BOOL)validateUploadRetryCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) TBMGridElement *gridElement;

//- (BOOL)validateGridElement:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet<TBMMessage*> *messages;

- (NSMutableSet<TBMMessage*>*)messagesSet;

@property (nonatomic, strong) NSSet<TBMVideo*> *videos;

- (NSMutableSet<TBMVideo*>*)videosSet;

@end

@interface _TBMFriend (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet<TBMMessage*>*)value_;
- (void)removeMessages:(NSSet<TBMMessage*>*)value_;
- (void)addMessagesObject:(TBMMessage*)value_;
- (void)removeMessagesObject:(TBMMessage*)value_;
@end

@interface _TBMFriend (VideosCoreDataGeneratedAccessors)
- (void)addVideos:(NSSet<TBMVideo*>*)value_;
- (void)removeVideos:(NSSet<TBMVideo*>*)value_;
- (void)addVideosObject:(TBMVideo*)value_;
- (void)removeVideosObject:(TBMVideo*)value_;
@end

@interface _TBMFriend (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveAbilities;
- (void)setPrimitiveAbilities:(NSNumber*)value;

- (int32_t)primitiveAbilitiesValue;
- (void)setPrimitiveAbilitiesValue:(int32_t)value_;

- (NSData*)primitiveAvatarImage;
- (void)setPrimitiveAvatarImage:(NSData*)value;

- (NSNumber*)primitiveAvatarTimestamp;
- (void)setPrimitiveAvatarTimestamp:(NSNumber*)value;

- (int64_t)primitiveAvatarTimestampValue;
- (void)setPrimitiveAvatarTimestampValue:(int64_t)value_;

- (NSNumber*)primitiveCid;
- (void)setPrimitiveCid:(NSNumber*)value;

- (int32_t)primitiveCidValue;
- (void)setPrimitiveCidValue:(int32_t)value_;

- (NSString*)primitiveCkey;
- (void)setPrimitiveCkey:(NSString*)value;

- (NSNumber*)primitiveEverSent;
- (void)setPrimitiveEverSent:(NSNumber*)value;

- (BOOL)primitiveEverSentValue;
- (void)setPrimitiveEverSentValue:(BOOL)value_;

- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;

- (NSString*)primitiveFriendshipCreatorMKey;
- (void)setPrimitiveFriendshipCreatorMKey:(NSString*)value;

- (NSString*)primitiveFriendshipStatus;
- (void)setPrimitiveFriendshipStatus:(NSString*)value;

- (NSNumber*)primitiveHasApp;
- (void)setPrimitiveHasApp:(NSNumber*)value;

- (BOOL)primitiveHasAppValue;
- (void)setPrimitiveHasAppValue:(BOOL)value_;

- (NSString*)primitiveIdTbm;
- (void)setPrimitiveIdTbm:(NSString*)value;

- (NSNumber*)primitiveIsFriendshipCreator;
- (void)setPrimitiveIsFriendshipCreator:(NSNumber*)value;

- (BOOL)primitiveIsFriendshipCreatorValue;
- (void)setPrimitiveIsFriendshipCreatorValue:(BOOL)value_;

- (NSNumber*)primitiveLastEventType;
- (void)setPrimitiveLastEventType:(NSNumber*)value;

- (int32_t)primitiveLastEventTypeValue;
- (void)setPrimitiveLastEventTypeValue:(int32_t)value_;

- (NSNumber*)primitiveLastIncomingVideoStatus;
- (void)setPrimitiveLastIncomingVideoStatus:(NSNumber*)value;

- (int32_t)primitiveLastIncomingVideoStatusValue;
- (void)setPrimitiveLastIncomingVideoStatusValue:(int32_t)value_;

- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;

- (NSNumber*)primitiveLastVideoStatusEventType;
- (void)setPrimitiveLastVideoStatusEventType:(NSNumber*)value;

- (int32_t)primitiveLastVideoStatusEventTypeValue;
- (void)setPrimitiveLastVideoStatusEventTypeValue:(int32_t)value_;

- (NSString*)primitiveMkey;
- (void)setPrimitiveMkey:(NSString*)value;

- (NSString*)primitiveMobileNumber;
- (void)setPrimitiveMobileNumber:(NSString*)value;

- (NSString*)primitiveOutgoingVideoId;
- (void)setPrimitiveOutgoingVideoId:(NSString*)value;

- (NSNumber*)primitiveOutgoingVideoStatus;
- (void)setPrimitiveOutgoingVideoStatus:(NSNumber*)value;

- (int32_t)primitiveOutgoingVideoStatusValue;
- (void)setPrimitiveOutgoingVideoStatusValue:(int32_t)value_;

- (NSDate*)primitiveTimeOfLastAction;
- (void)setPrimitiveTimeOfLastAction:(NSDate*)value;

- (NSNumber*)primitiveUploadRetryCount;
- (void)setPrimitiveUploadRetryCount:(NSNumber*)value;

- (int32_t)primitiveUploadRetryCountValue;
- (void)setPrimitiveUploadRetryCountValue:(int32_t)value_;

- (TBMGridElement*)primitiveGridElement;
- (void)setPrimitiveGridElement:(TBMGridElement*)value;

- (NSMutableSet<TBMMessage*>*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet<TBMMessage*>*)value;

- (NSMutableSet<TBMVideo*>*)primitiveVideos;
- (void)setPrimitiveVideos:(NSMutableSet<TBMVideo*>*)value;

@end
