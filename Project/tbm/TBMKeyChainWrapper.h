//
//  TBMKeyChainWrapper.h
//  tbm
//
//  Created by Sani Elfishawy on 1/3/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBMKeyChainWrapper : NSObject
+ (NSString *)getItem:(NSString *)key;
+ (void)putItem:(NSString *)key value:(NSString *)value;
+ (void)deleteItem:(NSString *)key;
@end
