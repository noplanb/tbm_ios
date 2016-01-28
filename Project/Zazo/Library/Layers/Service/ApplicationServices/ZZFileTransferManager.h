//
// Created by Rinat on 27.01.16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZFileTransferInterface.h"

@class AWSS3TransferUtility;

@interface ZZFileTransferManager : NSObject <ZZFileTransferInterface>

@property (nonatomic, copy) NSString *bucket;

- (void)updateCredentials;

@end

