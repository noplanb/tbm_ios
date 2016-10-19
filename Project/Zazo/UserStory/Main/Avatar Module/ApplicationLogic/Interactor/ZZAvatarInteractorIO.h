//
//  ZZAvatarInteractorIO.h
//  Zazo
//

typedef void(^ZZAvatarInteractorUploadCompletion)(NSError *error);

@protocol ZZAvatarInteractorInput <NSObject>

- (void)checkAvatarStatus;
- (void)uploadAvatar:(UIImage *)image completion:(ZZAvatarInteractorUploadCompletion)completion;
- (void)removeAvatarCompletion:(ZZAvatarInteractorUploadCompletion)completion;
- (BOOL)hasAvatar;

@end


@protocol ZZAvatarInteractorOutput <NSObject>

- (void)currentAvatarWasChanged:(UIImage *)avatar;
- (void)avatarEnabled:(BOOL)enabled;
- (void)avatarFetchDidComplete;
- (void)avatarFetchDidFail:(NSString *)text;

@end
