//
//  _TBMUser.h
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMUser.h instead.

extern const struct TBMUserAttributes
{
    __unsafe_unretained NSString *auth;
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *idTbm;
    __unsafe_unretained NSString *isInvitee;
    __unsafe_unretained NSString *isRegistered;
    __unsafe_unretained NSString *lastName;
    __unsafe_unretained NSString *mkey;
    __unsafe_unretained NSString *mobileNumber;
} TBMUserAttributes;

@interface TBMUserID : NSManagedObjectID
{
}
@end

@interface _TBMUser : NSManagedObject
{
}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;

+ (NSString *)entityName;

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc_;

@property (nonatomic, readonly, strong) TBMUserID *objectID;

@property (nonatomic, strong) NSString *auth;

//- (BOOL)validateAuth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString *firstName;

//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString *idTbm;

//- (BOOL)validateIdTbm:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber *isInvitee;

@property (atomic) BOOL isInviteeValue;

- (BOOL)isInviteeValue;

- (void)setIsInviteeValue:(BOOL)value_;

//- (BOOL)validateIsInvitee:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber *isRegistered;

@property (atomic) BOOL isRegisteredValue;

- (BOOL)isRegisteredValue;

- (void)setIsRegisteredValue:(BOOL)value_;

//- (BOOL)validateIsRegistered:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString *lastName;

//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString *mkey;

//- (BOOL)validateMkey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString *mobileNumber;

//- (BOOL)validateMobileNumber:(id*)value_ error:(NSError**)error_;

@end

@interface _TBMUser (CoreDataGeneratedPrimitiveAccessors)

- (NSString *)primitiveAuth;

- (void)setPrimitiveAuth:(NSString *)value;

- (NSString *)primitiveFirstName;

- (void)setPrimitiveFirstName:(NSString *)value;

- (NSString *)primitiveIdTbm;

- (void)setPrimitiveIdTbm:(NSString *)value;

- (NSNumber *)primitiveIsInvitee;

- (void)setPrimitiveIsInvitee:(NSNumber *)value;

- (BOOL)primitiveIsInviteeValue;

- (void)setPrimitiveIsInviteeValue:(BOOL)value_;

- (NSNumber *)primitiveIsRegistered;

- (void)setPrimitiveIsRegistered:(NSNumber *)value;

- (BOOL)primitiveIsRegisteredValue;

- (void)setPrimitiveIsRegisteredValue:(BOOL)value_;

- (NSString *)primitiveLastName;

- (void)setPrimitiveLastName:(NSString *)value;

- (NSString *)primitiveMkey;

- (void)setPrimitiveMkey:(NSString *)value;

- (NSString *)primitiveMobileNumber;

- (void)setPrimitiveMobileNumber:(NSString *)value;

@end
