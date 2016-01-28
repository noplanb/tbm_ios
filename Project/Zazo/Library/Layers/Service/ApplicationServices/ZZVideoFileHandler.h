//
// Created by Rinat on 27.01.16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZVideoFileHandlerInterface.h"
#import "ZZFileTransferInterface.h"

@interface ZZVideoFileHandler : NSObject <ZZVideoFileHandlerInterface>

@property (nonatomic, strong) id<ZZFileTransferInterface> fileTransfer;

@end