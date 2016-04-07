//
//  ANDrawerNC.h
//
//  Created by Oksana Kovalchuk on 6/17/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@class ANDrawerNC;

typedef NS_ENUM(NSInteger, ANDrawerOpenDirection)
{
    ANDrawerOpenDirectionFromLeft,
    ANDrawerOpenDirectionFromRight
};

typedef NS_ENUM(NSInteger, ANDrawerTopPin)
{
    ANDrawerTopPinNone,
    ANDrawerTopPinStatusBar,
    ANDrawerTopPinNavigationBar,
    ANDrawerTopPinCustomOffset,
};

@interface ANDrawerNC : UINavigationController

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) BOOL useBackground;
@property (nonatomic, assign) UIColor *backgroundColor;
@property (nonatomic, assign) BOOL closeOnPushNewController;
@property (nonatomic, assign) BOOL avoidKeyboard;
@property (nonatomic, assign) ANDrawerTopPin topPin;
@property (nonatomic, assign) CGFloat customTopPadding;

+ (instancetype)drawerWithView:(UIView *)view
                         width:(CGFloat)width
                     direction:(ANDrawerOpenDirection)direction;

- (void)toggle;
- (void)updateStateToOpened:(BOOL)isOpen;

@end
