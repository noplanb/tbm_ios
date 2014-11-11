//
//  TBMGridElement.h
//  tbm
//
//  Created by Sani Elfishawy on 11/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TBMVideoPlayer;
@class TBMFriend;

@interface TBMGridElement : NSManagedObject

@property (nonatomic, retain) TBMFriend *friend;
@property (nonatomic, retain) TBMVideoPlayer *videoPlayer;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic) NSInteger index;

// Create and destroy
+ (instancetype)create;
+ (void)destroyAll;

// Finders
+ (NSArray *)all;
+ (instancetype)findWithView:(UIView *)view;
+ (instancetype)findWithIndex:(NSInteger)i;
+ (instancetype)findWithFriend:(TBMFriend *)friend;
+ (BOOL)friendIsOnGrid:(TBMFriend *)friend;
+ (instancetype)firstEmptyGridElement;

// Utility
+ (void)printAll;

@end
