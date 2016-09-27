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
#import "ZZKeychainDataProvider.h"
#import <AWSRuntime/AWSRuntime.h>

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
        [self.output avatarUpdateDidFail];
    } completed:^{
        [self.output avatarUpdateDidComplete];
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
    ANDispatchBlockToBackgroundQueue(^{
        ZZS3CredentialsDomainModel *credentialsModel = [ZZKeychainDataProvider loadCredentialsOfType:ZZCredentialsTypeAvatar];
        
        if (!credentialsModel.isValid)
        {
            // TODO
            return;
        }
        
        ZZUserDomainModel *userModel = [ZZUserDataProvider authenticatedUser];
        
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:userModel.mkey
                                                                   withBucket:credentialsModel.bucket];
        
        AmazonCredentials *credentials =
            [[AmazonCredentials alloc] initWithAccessKey:credentialsModel.accessKey
                                           withSecretKey:credentialsModel.secretKey];
        request.credentials = credentials;
        S3GetObjectResponse *response = [[AmazonClientManager s3] getObject:request];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        UIImage *image = [UIImage imageWithData:response.body scale:scale];
        
        ANDispatchBlockToMainQueue(^{
            [self.output currentAvatarWasChanged:image];
        });
    });
}

- (void)avatarFetchFailed:(NSString * _Nonnull)errorText
{
    
}

@end
