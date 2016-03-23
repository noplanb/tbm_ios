//
//  ZZUserPresentationHelper.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@interface ZZUserPresentationHelper : NSObject

+ (NSString *)fullNameWithFirstName:(NSString*)firstName lastName:(NSString*)lastName;
+ (NSString *)abbreviationWithFullname:(NSString*)name;

@end
