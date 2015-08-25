//
//  TBMUser.h
//  tbm
//
//  Created by Sani Elfishawy on 5/1/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "_TBMUser.h"

@interface TBMUser : _TBMUser

//Added in v2
@property (nonatomic, retain) NSNumber* isInvitee; // TODO:

+ (instancetype)getUser;
+ (instancetype)createWithServerParams:(NSDictionary *)params;
+ (NSString *)phoneRegion;
+ (void)saveRegistrationData:(NSDictionary *)params;

- (void)setupRegistredFlagTo:(BOOL)registred;

@end
