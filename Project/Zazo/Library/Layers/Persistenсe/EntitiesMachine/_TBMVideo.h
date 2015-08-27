//
//  _TBMVideo.h
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMVideo.h instead.

extern const struct TBMVideoAttributes {
	__unsafe_unretained NSString *downloadRetryCount;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *videoId;
} TBMVideoAttributes;

extern const struct TBMVideoRelationships {
	__unsafe_unretained NSString *friend;
} TBMVideoRelationships;

@class TBMFriend;

@interface TBMVideoID : NSManagedObjectID {}
@end

@interface _TBMVideo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TBMVideoID* objectID;

@property (nonatomic, strong) NSNumber* downloadRetryCount;

@property (atomic) int32_t downloadRetryCountValue;
- (int32_t)downloadRetryCountValue;
- (void)setDownloadRetryCountValue:(int32_t)value_;

//- (BOOL)validateDownloadRetryCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* status;

@property (atomic) int32_t statusValue;
- (int32_t)statusValue;
- (void)setStatusValue:(int32_t)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* videoId;

//- (BOOL)validateVideoId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) TBMFriend *friend;

//- (BOOL)validateFriend:(id*)value_ error:(NSError**)error_;

@end

@interface _TBMVideo (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveDownloadRetryCount;
- (void)setPrimitiveDownloadRetryCount:(NSNumber*)value;

- (int32_t)primitiveDownloadRetryCountValue;
- (void)setPrimitiveDownloadRetryCountValue:(int32_t)value_;

- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (int32_t)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(int32_t)value_;

- (NSString*)primitiveVideoId;
- (void)setPrimitiveVideoId:(NSString*)value;

- (TBMFriend*)primitiveFriend;
- (void)setPrimitiveFriend:(TBMFriend*)value;

@end
