//
//  ZZAvatarManager.h
//  Zazo
//
//  Created by Rinat on 19/10/2016.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ZZAvatarUploadCompletion)(NSError *error);
extern NSString * const ZZAvatarWasChangedNotificationName;

@protocol ZZAvatarManagerDelegate <NSObject>

- (void)currentAvatarWasChanged:(UIImage *)avatar;
- (void)avatarEnabled:(BOOL)enabled;
- (void)avatarFetchDidComplete;
- (void)avatarFetchDidFail:(NSString *)text;

@end

@interface ZZAvatarManager : NSObject

@property (nonatomic, weak) id<ZZAvatarManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)checkAvatarStatus;
- (void)uploadAvatar:(UIImage *)image completion:(ZZAvatarUploadCompletion)completion;
- (void)removeAvatarCompletion:(ZZAvatarUploadCompletion)completion;
- (BOOL)hasAvatar;

@end
