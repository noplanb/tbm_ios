//
//  TBMS3CredentialsManager.h
//  tbm
//
//  Created by Sani Elfishawy on 1/5/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const S3_REGION_KEY;
extern NSString * const S3_BUCKET_KEY;
extern NSString * const S3_ACCESS_KEY;
extern NSString * const S3_SECRET_KEY;

@interface TBMS3CredentialsManager : NSObject
+ (void) refreshFromServer:(void (^)(BOOL))completionHandler;
+ (NSMutableDictionary *) credentials;
@end
