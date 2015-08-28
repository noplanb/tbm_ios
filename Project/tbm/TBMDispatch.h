//
//  TBMDispatch.h
//  tbm
//
//  Created by Sani Elfishawy on 1/6/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMUser;

// Dispatch type (via server or direct to rollbar)
typedef enum {
    TBMDispatchTypeSDK    = 0,
    TBMDispatchTypeServer = 1
} TBMDispatchType;

@interface TBMDispatch : NSObject

+ (void)enable;
+ (void)disable;
+ (void) dispatch: (NSString *)msg;

// Change dispatching type between SDK and Server
+ (void)setupDispatchType:(TBMDispatchType)type;

+ (void)startRollBar;
+ (void)setupRollBarUser:(TBMUser *)user;
+ (TBMDispatchType)dispatchType;
    
@end
