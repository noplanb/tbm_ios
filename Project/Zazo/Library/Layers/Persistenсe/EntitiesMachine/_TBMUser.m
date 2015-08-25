//
//  "_TBMUser.m"
//  $ProjectName
//
//  Created by ANODA.
//  Copyright (c) 2014 ANODA. All rights reserved.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMUser.m instead.

#import "_TBMUser.h"

const struct TBMUserAttributes TBMUserAttributes = {
	.auth = @"auth",
	.firstName = @"firstName",
	.idTbm = @"idTbm",
	.isRegistered = @"isRegistered",
	.lastName = @"lastName",
	.mkey = @"mkey",
	.mobileNumber = @"mobileNumber",
};

@implementation TBMUserID
@end

@implementation _TBMUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TBMUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TBMUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TBMUser" inManagedObjectContext:moc_];
}

- (TBMUserID*)objectID {
	return (TBMUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isRegisteredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isRegistered"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic auth;

@dynamic firstName;

@dynamic idTbm;

@dynamic isRegistered;

- (BOOL)isRegisteredValue {
	NSNumber *result = [self isRegistered];
	return [result boolValue];
}

- (void)setIsRegisteredValue:(BOOL)value_ {
	[self setIsRegistered:@(value_)];
}

- (BOOL)primitiveIsRegisteredValue {
	NSNumber *result = [self primitiveIsRegistered];
	return [result boolValue];
}

- (void)setPrimitiveIsRegisteredValue:(BOOL)value_ {
	[self setPrimitiveIsRegistered:@(value_)];
}

@dynamic lastName;

@dynamic mkey;

@dynamic mobileNumber;

@end

