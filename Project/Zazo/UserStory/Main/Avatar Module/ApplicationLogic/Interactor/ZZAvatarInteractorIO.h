//
//  ZZAvatarInteractorIO.h
//  Zazo
//

typedef void(^UploadCompletion)(NSError *error);

@protocol ZZAvatarInteractorInput <NSObject>

- (void)checkAvatarStatus;
- (void)uploadAvatar:(UIImage *)image completion:(UploadCompletion)completion;
- (void)removeAvatarCompletion:(UploadCompletion)completion;
- (BOOL)hasAvatar;

@end


@protocol ZZAvatarInteractorOutput <NSObject>

- (void)currentAvatarWasChanged:(UIImage *)avatar;
- (void)avatarEnabled:(BOOL)enabled;
- (void)avatarFetchDidComplete;
- (void)avatarFetchDidFail:(NSString *)text;

@end
