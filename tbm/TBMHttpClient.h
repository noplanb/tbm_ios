//
//  TBMHttpClient.h
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface TBMHttpClient : AFHTTPSessionManager
+ (instancetype)sharedClient;
@end
