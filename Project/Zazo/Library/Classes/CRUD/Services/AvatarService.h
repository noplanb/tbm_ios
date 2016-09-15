//
//  AvatarService.h
//  Zazo
//
//  Created by Rinat on 15/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#ifndef AvatarService_h
#define AvatarService_h

@class RACSignal;

@protocol LegacyAvatarService

- (RACSignal *)legacyGet;
- (RACSignal *)legacySet:(UIImage *)image;
- (RACSignal *)legacyDelete;

@end

#endif /* AvatarService_h */
