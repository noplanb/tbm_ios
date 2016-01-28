//
//  ZZFileTransferInterface.h
//  Zazo
//
//  Created by Rinat on 27.01.16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZZFileTransferInterface <NSObject>

- (void)uploadFile:(NSURL *)localFilePath
                to:(NSString *)key
          metadata:(NSDictionary <NSString *, NSString *> *)metadata
        completion:(ANCompletionBlock)aCompletion;

- (void)downloadFile:(NSString *)key
                  to:(NSURL *)localFilePath
          completion:(ANCompletionBlock)aCompletion;

- (void)deleteFile:(NSString *)key
        completion:(ANCompletionBlock)aCompletion;

@end

