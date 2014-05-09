//
//  TBMUploadManager.h
//  tbm
//
//  Created by Sani Elfishawy on 5/6/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBMUploadManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

+ (instancetype)sharedManager;
+ (NSString *)sessionIdentifier;

- (void) uploadWithFriendId:(NSString *)friendId;

@end
