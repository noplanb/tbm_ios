//
//  TBMVersionHandler.h
//  tbm
//
//  Created by Sani Elfishawy on 8/20/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMVersionHandlerDelegate <NSObject>
- (void)versionCheckCallback:(NSString *)result;
@end

@interface TBMVersionHandler : NSObject
- (instancetype) initWithDelegate:(id<TBMVersionHandlerDelegate>)delegate;
- (void) checkVersionCompatibility;

+ (BOOL) updateSchemaRequired:(NSString *)result;
+ (BOOL) updateRequired:(NSString *)result;
+ (BOOL) updateOptional:(NSString *)result;
+ (BOOL) current:(NSString *)result;

@end
