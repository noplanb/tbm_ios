//
//  ZZMenuInteractorIO.h
//  Zazo
//

@class ANMessageDomainModel;

@protocol ZZMenuInteractorInput <NSObject>

- (NSString *)username;
- (void)checkAvatarForUpdate;
- (void)uploadAvatar:(UIImage *)image;
- (void)loadFeedbackModel;
- (void)removeAvatar;

@end


@protocol ZZMenuInteractorOutput <NSObject>

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel *)model;
- (void)currentAvatarWasChanged:(UIImage *)avatar;
- (void)avatarUpdateDidComplete;
- (void)avatarFetchDidComplete;
- (void)avatarUpdateDidFail;

@end
