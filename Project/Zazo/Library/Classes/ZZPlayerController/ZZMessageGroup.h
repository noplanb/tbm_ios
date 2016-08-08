//
//  ZZMessageGroup.h
//  Zazo
//
//  Created by Rinat on 08/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZPlaybackQueueItem.h"
#import "ZZMessageDomainModel.h"

@interface ZZMessageGroup : NSObject <ZZPlaybackQueueItem>

@property (nonatomic, strong, readonly) NSArray <ZZMessageDomainModel *> *messages;
@property (nonatomic, strong) NSString *name;

- (void)addMessage:(ZZMessageDomainModel *)message;

@end
