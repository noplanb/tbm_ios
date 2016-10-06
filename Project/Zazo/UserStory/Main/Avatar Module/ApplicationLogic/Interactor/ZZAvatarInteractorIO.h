//
//  ZZAvatarInteractorIO.h
//  Zazo
//

typedef void(^UploadCompletion)(NSError *error);

@protocol ZZAvatarInteractorInput <NSObject>

- (void)checkAvatarForUpdate;
- (void)uploadAvatar:(UIImage *)image completion:(UploadCompletion)completion;
- (void)removeAvatarCompletion:(UploadCompletion)completion;
- (BOOL)hasAvatar;


@end


@protocol ZZAvatarInteractorOutput <NSObject>

- (void)currentAvatarWasChanged:(UIImage *)avatar;
- (void)avatarFetchDidComplete;
- (void)avatarUpdateDidFail;

@end
