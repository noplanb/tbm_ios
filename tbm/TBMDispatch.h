//
//  TBMDispatch.h
//  tbm
//
//  Created by Sani Elfishawy on 1/6/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMUser;

@interface TBMDispatch : NSObject

+ (void)enable;
+ (void)disable;
+ (void) dispatch: (NSString *)msg;
+ (void)startRollBar;
+ (void)setRollBarUser:(TBMUser *)user;

@end
