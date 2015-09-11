//
//  TBMVersionHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 8/20/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMVersionHandler.h"
#import "TBMConfig.h"
#import "TBMStringUtils.h"
#import "OBLogger.h"
#import "NSObject+ANSafeValues.h"
#import "NSString+ANAdditions.h"
#import "ZZCommonNetworkTransport.h"

static const NSString *VH_RESULT_KEY = @"result";
static const NSString *VH_UPDATE_SCHEMA_REQUIRED = @"update_schema_required";
static const NSString *VH_UPDATE_REQUIRED = @"update_required";
static const NSString *VH_UPDATE_OPTIONAL = @"update_optional";
static const NSString *VH_CURRENT = @"current";

@interface TBMVersionHandler()

@property (nonatomic, retain) id<TBMVersionHandlerDelegate> delegate;

@end

@implementation TBMVersionHandler

- (instancetype) initWithDelegate:(id<TBMVersionHandlerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

+ (BOOL) updateSchemaRequired:(NSString *)result
{
    return [result isEqual:VH_UPDATE_SCHEMA_REQUIRED];
}
+ (BOOL) updateRequired:(NSString *)result{
    return [result isEqual:VH_UPDATE_REQUIRED];
}
+ (BOOL) updateOptional:(NSString *)result{
    return [result isEqual:VH_UPDATE_OPTIONAL];
}
+ (BOOL) current:(NSString *)result{
    return [result isEqual:VH_CURRENT];
}

+ (void) goToStore{
    
}

- (void) checkVersionCompatibility
{
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    version = [version an_stripAllNonNumericCharacters];
    NSDictionary* parameters = @{@"device_platform": @"ios",
                                 @"version": @([version integerValue])};
    
    [[ZZCommonNetworkTransport checkApplicationVersionWithParameters:parameters] subscribeNext:^(id x) {
        OB_INFO(@"checkVersionCompatibility: success: %@", [x objectForKey:@"result"]);
        if (_delegate)
        {
            [_delegate versionCheckCallback:[x objectForKey:VH_RESULT_KEY]];
        }
    } error:^(NSError *error) {
        OB_WARN(@"checkVersionCompatibility: %@", error);
    }];
}

@end
