//
//  ZZAvatarInteractor.m
//  Zazo
//

#import "ZZAvatarInteractor.h"
#import "ZZAvatar.h"
#import "ZZAvatarManager.h"

@interface ZZAvatarInteractor () <ZZAvatarManagerDelegate>

@end

@implementation ZZAvatarInteractor

- (instancetype)init
{
    self = [super init];
    if (self) {
        [ZZAvatarManager sharedManager].delegate = self;
    }
    return self;
}

- (void)checkAvatarStatus
{
    [[ZZAvatarManager sharedManager] checkAvatarStatus];
}

- (void)uploadAvatar:(UIImage *)image completion:(ZZAvatarInteractorUploadCompletion)completion
{
    [[ZZAvatarManager sharedManager] uploadAvatar:image completion:completion];
}

- (void)removeAvatarCompletion:(ZZAvatarInteractorUploadCompletion)completion
{
    [[ZZAvatarManager sharedManager] removeAvatarCompletion:completion];
}

- (BOOL)hasAvatar
{
    return [[ZZAvatarManager sharedManager] hasAvatar];
}

#pragma mark ZZAvatarManagerDelegate

- (void)currentAvatarWasChanged:(UIImage *)avatar
{
    [self.output currentAvatarWasChanged:avatar];
}

- (void)avatarEnabled:(BOOL)enabled
{
    [self.output avatarEnabled:enabled];
}

- (void)avatarFetchDidComplete
{
    [self.output avatarFetchDidComplete];
}

- (void)avatarFetchDidFail:(NSString *)text
{
    [self.output avatarFetchDidFail:text];
}


@end
