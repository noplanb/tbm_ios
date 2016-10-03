//
//  ZZMenuInteractorIO.h
//  Zazo
//

@class ANMessageDomainModel;

typedef void(^UploadCompletion)(NSError *error);

@protocol ZZMenuInteractorInput <NSObject>

- (NSString *)username;
- (void)checkAvatarForUpdate;
- (void)uploadAvatar:(UIImage *)image completion:(UploadCompletion)completion;
- (void)removeAvatarCompletion:(UploadCompletion)completion;
- (void)loadFeedbackModel;
- (BOOL)hasAvatar;

@end


@protocol ZZMenuInteractorOutput <NSObject>

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel *)model;
- (void)currentAvatarWasChanged:(UIImage *)avatar;
- (void)avatarFetchDidComplete;
- (void)avatarUpdateDidFail;

@end
