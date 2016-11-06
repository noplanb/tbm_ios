//
//  ZZAvatarManager.m
//  Zazo
//
//  Created by Rinat on 19/10/2016.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZAvatarManager.h"
#import "ZZKeychainDataProvider.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZUserDataProvider.h"

@import AWSS3;

NSString * const ZZAvatarWasChangedNotificationName = @"ZZAvatarWasChangedNotificationName";

@interface ZZAvatarManager () <AvatarUpdateServiceDelegate>

@property (nonatomic, assign) BOOL areCredentialsLoaded;

@property (nonatomic, strong) AvatarUpdateService *updateService;
@property (nonatomic, strong) AvatarStorageService *storageService;
@property (nonatomic, strong) id<LegacyAvatarService> networkService;

@end

@implementation ZZAvatarManager

+ (instancetype)sharedManager
{
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZZAvatarManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NetworkClient *networkClient = [NetworkClient new];
        networkClient.baseURL = [NSURL URLWithString: APIBaseURL()];
        
        ConcreteAvatarService *avatarService = [[ConcreteAvatarService alloc] init];
        avatarService.networkClient = networkClient;
        
        NSString *persistenceKey = @"avatar";
        AvatarUpdateService *updateService = [[AvatarUpdateService alloc] initWith:persistenceKey];
        updateService.legacyAvatarService = avatarService;
        updateService.delegate = self;
        
        _networkService = avatarService;
        _updateService = updateService;
        _storageService = [AvatarStorageService sharedService];

        
    }
    return self;
}


- (void)checkAvatarStatus
{
    [self currentAvatarWasChanged:[self.storageService get]];
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
    } error:^(NSError *error) {
        [self avatarFetchFailed:error.localizedDescription];
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

- (void)uploadAvatar:(UIImage *)image completion:(ZZAvatarUploadCompletion)completion;
{
    [[self.networkService legacySet:image] subscribeError:^(NSError *error) {
        completion(error);
    } completed:^{
        completion(nil);
    }];
}

- (void)removeAvatarCompletion:(ZZAvatarUploadCompletion)completion
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
    [self currentAvatarWasChanged:nil];
    [self.delegate avatarFetchDidComplete];
}

- (void)avatarEnabled:(BOOL)enabled
{
    [self.delegate avatarEnabled:enabled];
}

- (void)avatarUpdatedWith:(int64_t)timestamp completion:(ANCodeBlock)completion
{
    ANDispatchBlockToBackgroundQueue(^{
        
        AWSS3 *avatarService = [AWSS3 S3ForKey:ZZCredentialsTypeAvatar];
        
        ZZS3CredentialsDomainModel *credentialsModel = [ZZKeychainDataProvider loadCredentialsOfType:ZZCredentialsTypeAvatar];
        ZZUserDomainModel *userModel = [ZZUserDataProvider authenticatedUser];
        
        AWSS3GetObjectRequest *request = [AWSS3GetObjectRequest new];
        request.bucket = credentialsModel.bucket;
        request.key = [NSString stringWithFormat: @"%@_%lld", userModel.mkey, timestamp];
        
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
            
            completion();
            
            ANDispatchBlockToMainQueue(^{
                [self currentAvatarWasChanged:image];
                [self.delegate avatarFetchDidComplete];
            });
            
            return nil;
        }];
    });
}

- (void)avatarUpToDate
{
    [self.delegate avatarFetchDidComplete];
}

- (void)avatarFetchFailed:(NSString * _Nonnull)errorText
{
    [self.delegate avatarFetchDidFail:errorText];
}

- (void)currentAvatarWasChanged:(UIImage *)image
{
    [self.delegate currentAvatarWasChanged:image];
    [[NSNotificationCenter defaultCenter] postNotificationName:ZZAvatarWasChangedNotificationName object:image];
}

@end
