//
//  ZZFeatureObserver.h
//  Zazo
//
//  Created by ANODA on 9/17/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZFeatureObserver : NSObject

+ (instancetype)sharedInstance;
- (BOOL)isBothCameraEnabled;
- (BOOL)isRecordAbortWithDraggedEnabled;
- (BOOL)isDeleteFriendsEnabled;
- (BOOL)isEarpieceEnabled;
- (BOOL)isSpinWeelEnabled;

@end
