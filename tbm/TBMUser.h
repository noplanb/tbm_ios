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
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * idTbm;
@property (nonatomic, retain) NSString * auth;
@property (nonatomic, retain) NSString * mkey;
@property (nonatomic, retain) NSString * mobileNumber;

+ (instancetype)getUser;
+ (instancetype)createWithIdTbm:(NSNumber *)idTbm;
+ (instancetype)createWithServerParams:(NSDictionary *)params;

@end
