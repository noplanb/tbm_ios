//
//  ZZBaseLockController.h
//  Zazo
//
//  Created by ANODA on 22/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenStrategy.h"
#import "ZZSecretScreenObserveTypes.h"

@interface ZZBaseTouchController : NSObject

@property (nonatomic, strong) id <ZZSecretScreenStrategy> strategy;
@property (nonatomic, assign) NSInteger startTimeStamp;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, strong) NSMutableArray* checkFrameModelsArray;
@property (nonatomic, assign) NSMutableArray* resultArray;
@property (nonatomic, copy) void(^completionBlock)();
@property (nonatomic, assign) CGFloat touchDelay;

@property (nonatomic, assign) BOOL isAbleToMoving;
@property (nonatomic, assign) BOOL isStartObserving;

- (void)observeTouch:(UITouch*)touch withEvent:(id)event;

- (void)startObservingIfNeededWithTouch:(UITouch*)touch withEvent:(UIEvent*)event;
- (void)observeEndTouchBeforeBeginObservingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event;
- (void)observeMovingWithTouch:(UITouch *)touch;
- (void)resetObserving;


@end
