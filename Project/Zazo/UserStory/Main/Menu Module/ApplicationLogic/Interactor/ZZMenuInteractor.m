//
//  ZZMenuInteractor.m
//  Zazo
//

#import "ZZMenuInteractor.h"
#import "ZZMenu.h"
#import "ZZUserDomainModel.h"
#import "ZZUserDataProvider.h"
#import "ZZCommonModelsGenerator.h"
#import "ZZKeychainDataProvider.h"
#import "ZZCommonNetworkTransportService.h"

@import AWSS3;

@interface ZZMenuInteractor ()

@property (nonatomic, assign) BOOL areCredentialsLoaded;
@property (nonatomic, strong) UIImage *imageForRetry;

@end

@implementation ZZMenuInteractor

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

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
    [self.output currentAvatarWasChanged:[self.storageService get]];    
    [self updateConfiguration];
    
    if (self.areCredentialsLoaded)
    {
        [self.updateService checkUpdate];
        return;
    }
    
    [[ZZCommonNetworkTransportService loadS3CredentialsOfType:ZZCredentialsTypeAvatar] subscribeNext:^(id x) {
        if ([self updateConfiguration])
        {
            self.areCredentialsLoaded = YES;
            [self.updateService checkUpdate];
        }
    }];
}

- (BOOL)hasAvatar
{
    return self.storageService.get != nil;
}

- (BOOL)updateConfiguration
{
    ZZS3CredentialsDomainModel *credentialsModel = [ZZKeychainDataProvider loadCredentialsOfType:ZZCredentialsTypeAvatar];
    
    if (!credentialsModel.isValid)
    {
        return NO;
    }
    
    AWSStaticCredentialsProvider *credentials =
    [[AWSStaticCredentialsProvider alloc] initWithAccessKey:credentialsModel.accessKey
                                                  secretKey:credentialsModel.secretKey];
    
    AWSRegionType region = [credentialsModel.region aws_regionTypeValue];
    
    AWSServiceConfiguration *configuration =
    [[AWSServiceConfiguration alloc] initWithRegion:region
                                credentialsProvider:credentials];
    
    [AWSS3 registerS3WithConfiguration:configuration
                                forKey:ZZCredentialsTypeAvatar];
    
    return YES;
}

- (void)uploadAvatar:(UIImage *)image completion:(UploadCompletion)completion;
{
    [[self.networkService legacySet:image] subscribeError:^(NSError *error) {
        completion(error);
    } completed:^{
        completion(nil);
    }];
}

- (void)removeAvatarCompletion:(UploadCompletion)completion
{
    [[self.networkService legacyDelete] subscribeError:^(NSError *error) {
        completion(error);
    } completed:^{
        completion(nil);
    }];
}

// MARK: AvatarUpdateServiceDelegate

- (void)avatarRemoved
{
    [self.storageService remove];
    [self.output currentAvatarWasChanged:nil];
}

- (void)updateAvatarWith:(NSTimeInterval)timestamp completion:(ANCodeBlock)completion
{
    ANDispatchBlockToBackgroundQueue(^{
        
        AWSS3 *avatarService = [AWSS3 S3ForKey:ZZCredentialsTypeAvatar];
    
        ZZS3CredentialsDomainModel *credentialsModel = [ZZKeychainDataProvider loadCredentialsOfType:ZZCredentialsTypeAvatar];
        ZZUserDomainModel *userModel = [ZZUserDataProvider authenticatedUser];

        AWSS3GetObjectRequest *request = [AWSS3GetObjectRequest new];
        request.bucket = credentialsModel.bucket;
        request.key = [NSString stringWithFormat: @"%@_%1.0f", userModel.mkey, timestamp];
        
        [[avatarService getObject:request] continueWithBlock:^id _Nullable(AWSTask<AWSS3GetObjectOutput *> * _Nonnull task) {
            
            if (task.error != nil)
            {
                [self avatarFetchFailed:task.error.localizedDescription];
                return nil;
            }
            
            CGFloat scale = [UIScreen mainScreen].scale;
            AWSS3GetObjectOutput *output = (AWSS3GetObjectOutput*)task.result;
            UIImage *image = [UIImage imageWithData:output.body scale:scale];
            [self.storageService updateWith:image];
            
            ANDispatchBlockToMainQueue(^{
                [self.output currentAvatarWasChanged:image];
                [self.output avatarFetchDidComplete];
            });

            return nil;
        }];
    });
}

- (void)avatarFetchFailed:(NSString * _Nonnull)errorText
{
    [self.output avatarUpdateDidFail];
}

@end
