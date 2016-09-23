//
//  ZZMenuInteractor.m
//  Zazo
//

#import "ZZMenuInteractor.h"
#import "ZZMenu.h"
#import "ZZUserDomainModel.h"
#import "ZZUserDataProvider.h"
#import "ZZCommonModelsGenerator.h"
#import "AmazonClientManager.h"

@implementation ZZMenuInteractor

- (NSString *)username
{
    ZZUserDomainModel *user = [ZZUserDataProvider authenticatedUser];
    return user.fullName;
}

- (void)loadFeedbackModel
{
    ZZUserDomainModel *user = [ZZUserDataProvider authenticatedUser];
    [self.output feedbackModelLoadedSuccessfully:[ZZCommonModelsGenerator feedbackModelWithUser:user]];
}

- (void)checkAvatarForUpdate
{
    [self.updateService checkUpdate];
}

- (void)uploadAvatar:(UIImage *)image;
{
    [[self.networkService legacySet:image] subscribeError:^(NSError *error) {
        [self.output avatarUpdateDidComplete];
    } completed:^{
        [self.output avatarUpdateDidFail];
    }];
}

- (void)removeAvatar
{
//    [[self.networkService legacyDelete] subscribeError:^(NSError *error) {
//        
//    } completed:^{
//        
//    }];
}

// MARK: AvatarUpdateServiceDelegate

- (void)avatarNeedsToBeUpdated:(ANCodeBlock _Nonnull)completion
{
//    S3GetObjectRequest *request = [S3GetObjectRequest alloc] initWithKey:<#(NSString *)#> withBucket:<#(NSString *)#>
//    [AmazonClientManager s3] getObject:( *)
}

- (void)avatarFetchFailed:(NSString * _Nonnull)errorText
{
    
}

@end
