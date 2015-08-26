//
//  TBMUser.h
//  tbm
//
//  Created by Sani Elfishawy on 5/1/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBMUser : NSManagedObject
@property (nonatomic, retain) NSString * auth;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * idTbm;
@property (nonatomic, assign) BOOL isRegistered;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * mkey;
@property (nonatomic, retain) NSString * mobileNumber;

//Added in v2
@property (nonatomic, retain) NSNumber * isInvitee;

+ (instancetype)getUser;
+ (instancetype)createWithServerParams:(NSDictionary *)params;
+ (NSString *)phoneRegion;

+ (void)saveRegistrationData:(NSDictionary *)params;

- (void)setupRegisteredFlagTo:(BOOL)registred;
- (void)setupIsInviteeFlagTo:(BOOL)flag;
@end
