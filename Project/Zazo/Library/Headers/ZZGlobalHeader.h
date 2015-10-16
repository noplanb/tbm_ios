//
//  ANGlobalHeader
//
//  Created by ANODA on 2/2/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

//#define DEBUG_CONTROLLER

#ifdef DEBUG

//#define HTTPLog
//#define DEBUG_LOGIN_USER
//#define STAGESERVER
//#define HINTS

#endif

//helpers
#import "NSObject+ANSafeValues.h"
#import "ANHelperFunctions.h"
#import "ANLogger.h"
#import "ANDefines.h"

#import "FrameAccessor.h"
#import "Masonry.h"

//reactive cocoa
#import "RACEXTScope.h"
#import "ReactiveCocoa.h"
#import "RACCommand+ANAdditions.h"

#import "ZZColorTheme.h"


//#pragma mark - UI Categories

#import "UIFont+ANAdditions.h"
#import "UIColor+ANAdditions.h"
#import "UIImage+PDF.h"
#import "UINavigationItem+ANAdditions.h"
#import "UIBarButtonItem+ANAdditions.h"

#import "ANProgressButton.h"
#import "NSDate+ANUIAdditions.h"
#import "UIImage+ANAdditions.h"
#import "OBLogger.h"


//TODO: cleanup this

//email constants

static NSString* kApplicationFeedbackEmailSubject = @"Feedback";
static NSString* kApplicationFeedbackEmailAddress = @"feedback@zazoapp.com";
//ios, app version, user mkey, iphone 5s.

static NSString* const kContentDBName = @"tbm";

static NSString* const kAppstoreURLString = @"https://itunes.apple.com/us/app/zazo/id922294638";
static NSString* const kMessageSoundEffectFileName = @"BeepSin30.wav";
static NSString* const kMessageSoundZazoFileName = @"NotificationTone.wav";


#define DEBUG_MODE
#ifdef DEBUG_MODE
#define DebugLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define IS_IPHONE_4             ([[UIScreen mainScreen] bounds].size.height == 480.0f)


typedef void(^ZZBoolBlock)(BOOL isSuccess);
