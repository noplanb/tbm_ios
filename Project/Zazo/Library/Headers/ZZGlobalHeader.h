//
//  ANGlobalHeader
//
//  Created by ANODA on 2/2/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#ifdef RELEASE
#warning Don't forget update this number
#endif
static NSString* const kGlobalApplicationVersion = @"38";


//#define DEBUG_CONTROLLER

#ifdef DEBUG
#define HTTPLog
#define DEBUG_LOGIN_USER
#define STAGESERVER
#define HINTS
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
#import "ZZConstants.h"


#define ZZLogInfo(s, ... ) OB_INFO(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define ZZLogWarning(s, ... ) OB_WARN(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define ZZLogError(s, ... ) OB_ERROR(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define ZZLogDebug(s, ... ) OB_DEBUG(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define ZZLogEvent(s, ... ) OB_EVENT(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define IS_IPHONE_4             ([[UIScreen mainScreen] bounds].size.height == 480.0f)


typedef void(^ZZBoolBlock)(BOOL isSuccess);





