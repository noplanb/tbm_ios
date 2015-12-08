//
//  ZZUpdateCredentialsManager.h
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZUpdateCredentialsManager : NSObject

- (void)updateCredentialsWithCompletion:(ANCodeBlock)completionBlock;
- (void)loadFriends:(ANCodeBlock)completionBlock;

@end
