//
//  ANGlobalHeader
//
//  Created by ANODA on 2/2/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#ifdef RELEASE
//#error Don't forget update this number
#endif
static NSString* const kGlobalApplicationVersion = @"51";


//#define DEBUG_CONTROLLER

#ifdef DEBUG
//#define HTTPLog
#define DEBUG_LOGIN_USER
#define STAGESERVER
#define HINTS
//#define MAKING_SCREENSHOTS
#endif

//swiftas

#ifdef TESTS
#import "ZazoTests-Swift.h"
#else
#import "Zazo-Swift.h"  
#endif

//helpers
#import "NSObject+ANSafeValues.h"
#import "ANHelperFunctions.h"
#import "ZZDispatchHelper.h"
#import "ANDefines.h"
#import "FrameAccessor.h"
#import "Masonry.h"
#import "RACCommand+ANAdditions.h"
#import "ZZColorTheme.h"

//#pragma mark - UI Categories

#import "UIFont+ZZAdditions.h"
#import "UIColor+ANAdditions.h"
#import "UIImage+PDF.h"
#import "UINavigationItem+ANAdditions.h"
#import "UIBarButtonItem+ANAdditions.h"

#import "NSDate+ANUIAdditions.h"
#import "UIImage+ANAdditions.h"
#import "OBLogger.h"
#import "ZZConstants.h"

@import Crashlytics;

#define ZZLogInfo(s, ... ) OB_INFO(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define ZZLogWarning(s, ... ) OB_WARN(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define ZZLogError(s, ... ) OB_ERROR(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define ZZLogDebug(s, ... ) OB_DEBUG(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define ZZLogEvent(s, ... ) OB_EVENT(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

typedef void(^ZZBoolBlock)(BOOL isSuccess);
