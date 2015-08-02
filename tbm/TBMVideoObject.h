//
// Created by Maksim Bazarov on 30.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMDispatchProtocol.h"

@interface TBMVideoObject : NSObject <TBMDispatchProtocol>
@property(nonatomic, strong) NSString *videoID;
@property(nonatomic, strong) NSString *videoStatus;

/**
* TBMVideoObject Object maker
* status is TBMIncomingVideoStatus or TBMOutgoingVideoStatus as string
*/
+ (TBMVideoObject *)makeVideoObjectWithVideoID:(NSString *)videoID status:(NSString *)status;
@end