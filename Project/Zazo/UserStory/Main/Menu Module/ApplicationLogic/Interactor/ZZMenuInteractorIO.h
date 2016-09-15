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

@end


@protocol ZZMenuInteractorOutput <NSObject>

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel *)model;
- (void)avatarUpdateDidComplete;
- (void)avatarUpdateDidFail;

@end