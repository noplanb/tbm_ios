//
//  ANDefines.h
//
//  Created by Oksana Kovalchuk on 28/6/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#pragma mark - iPhone Device Number

#define IS_IPHONE_4             ([[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5             ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6             ([[UIScreen mainScreen] bounds].size.height == 667.f)
#define IS_IPHONE_6_PLUS        ([[UIScreen mainScreen] bounds].size.height == 736.f)
#define IS_IPHONE_5_OR_HIGHER   ([[UIScreen mainScreen] bounds].size.height >= 568.0f)


#pragma mark - iPad Constants

#define IS_IPAD                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#pragma mark - Screen scale

#define IS_RETINA               ([UIScreen mainScreen].scale >= 2)
#define IS_EXTRA_RETINA         ([UIScreen mainScreen].scale == 3)

#pragma mark - IOS Version

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION          ([[[UIDevice currentDevice] systemVersion] floatValue])
#define IOS8                    (8.0 <= SYSTEM_VERSION && SYSTEM_VERSION < 9.0)


#pragma mark - Device Orientation

#define IS_PORTRAIT     UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])

#pragma mark Callbacks

typedef void (^ANCodeBlock)(void);

typedef void (^ANCompletionBlock)(NSError *error);

typedef BOOL (^ANValidationBlock)();
