//
//  ZZCredentialsProvider.h
//  Zazo
//
//  Created by Rinat on 22/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Fetches, stores and provides S3 credentials
 */
@interface ZZCredentialsProvider : NSObject

- (instancetype)sharedProvider;
- (ZZS3CredentialsDomainModel *)credentialsOfType:(NSString *)type;
- (void)updateCredentialsOfType:(NSString *)type completion:(ANCodeBlock)completion;

@end