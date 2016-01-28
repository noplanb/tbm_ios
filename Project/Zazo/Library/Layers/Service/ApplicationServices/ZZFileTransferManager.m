//
// Created by Rinat on 27.01.16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZFileTransferManager.h"
#import "AWSS3TransferUtility.h"
#import "ZZKeychainDataProvider.h"
#import "ZZCommonNetworkTransportService.h"
#import <AWSS3/AWSS3.h>

static NSString * const AWSS3Key = @"ZZFileTransferManager";

@interface ZZUploadDataModel: NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSURL *filePath;
@property (nonatomic, copy) ANCompletionBlock completion;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) NSUInteger attemptCount;
@property (nonatomic, copy) NSDictionary <NSString *, NSString *> *metadata;

@end

@implementation ZZUploadDataModel

@end

@implementation ZZFileTransferManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _updateCredentialsIfPossible];
    }
    return self;
}

- (void)downloadFile:(NSString *)key
                  to:(NSURL *)localFilePath
          completion:(ANCompletionBlock)aCompletion;
{
    
    [[AWSS3TransferUtility S3TransferUtilityForKey:AWSS3Key] downloadToURL:localFilePath
                                                                    bucket:self.bucket
                                                                       key:key
                                                                expression:nil
                                                          completionHander:^(AWSS3TransferUtilityDownloadTask * _Nonnull task, NSURL * _Nullable location, NSData * _Nullable data, NSError * _Nullable error) {
                                                              
                                                              if (aCompletion)
                                                              {
                                                                  aCompletion(error);
                                                              }
                                                          }];

}

- (void)_upload:(ZZUploadDataModel *)uploadModel
{
    uploadModel.attemptCount++;
    
    AWSS3TransferUtilityUploadExpression *expression = [[AWSS3TransferUtilityUploadExpression alloc] init];
    
    if (!ANIsEmpty(uploadModel.metadata))
    {
        [uploadModel.metadata enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [expression setValue:obj forRequestParameter:key];
        }];
    }
    
    [[AWSS3TransferUtility S3TransferUtilityForKey:AWSS3Key] uploadFile:uploadModel.filePath
                                                                 bucket:self.bucket
                                                                    key:uploadModel.key
                                                            contentType:@"video/mp4"
                                                             expression:expression
                                                       completionHander:^(AWSS3TransferUtilityUploadTask * _Nonnull task, NSError * _Nullable error) {
                                                           
                                                           uploadModel.task = [task performSelector:NSSelectorFromString(@"sessionTask")];
                                                           uploadModel.error = error;
                                                           
                                                           [self _uploadCompleted:uploadModel];
                                                           
                                                       }];
    

}

- (void)_uploadCompleted:(ZZUploadDataModel *)uploadModel
{
    NSURLSessionTask *task = uploadModel.task;
    
    NSError *clientError = uploadModel.error;
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;

    NSError *serverError = [self createErrorFromHttpResponse:response.statusCode];

    if ( task.state != NSURLSessionTaskStateCompleted ) {
        ZZLogError(@"Indicated that task completed but state = %d", (int) task.state );
        return;
    }

    NSError *error = nil;

    if (serverError != nil || clientError != nil)
    {
        if (clientError != nil)
        {
//            OB_WARN(@"%@ File Transfer for %@ received client error: %@", transferType, marker, clientError);
            error = clientError;
        }

        if (serverError != nil)
        {
//            OB_WARN(@"%@ File Transfer for %@ received server error %@",transferType, marker, serverError);
            error = serverError;
        }

        BOOL shouldRetry = [self isRetryableClientError:clientError] && [self isRetryableServerError:serverError];
        
        if (shouldRetry)
        {
            
            NSTimeInterval seconds = [self retryTimeoutValue:uploadModel.attemptCount];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self _upload:uploadModel];
            });
            
            
            
//            [self.delegate fileTransferRetrying:marker attemptCount: obtask.attemptCount  withError:error];
        }
        else
        {
//            [self handleCompleted:task obtask:obtask error:error];
            
            uploadModel.completion(error);
            
//            OB_WARN(@"%@ for %@ done with error %@", transferType, marker, error);
        }
        
    }
    
    else
    {
        uploadModel.completion(nil);
    }


}

// Returns the timer value (in seconds) given the retry attempt
-(NSTimeInterval) retryTimeoutValue: (NSUInteger)retryAttempt
{
    //    return (NSTimeInterval)10.0;
    return (NSTimeInterval)10*(1<<(retryAttempt-1));
}

- (void)uploadFile:(NSURL *)localFilePath
                to:(NSString *)key
          metadata:(NSDictionary <NSString *, NSString *> *)metadata
        completion:(ANCompletionBlock)aCompletion;
{
    ZZUploadDataModel *uploadModel = [ZZUploadDataModel new];
    
    uploadModel.key = key;
    uploadModel.completion = aCompletion;
    uploadModel.filePath = localFilePath;
    uploadModel.metadata = metadata;
    
    [self _upload:uploadModel];
}

// Note this is correct handling for S3 errors. If we find that various agents are different with respect to determining permanent failures
// then we probably need to move this method in the agent.
- (BOOL)isRetryableServerError:(NSError *)error{
    if (error == nil)
        return YES;
    
    if (error.code/100 == 4)
        return NO;
    
    if (error.code == 501)
        return NO;
    
    if (error.code == 301)
        return NO;
    
    return YES;
}

- (BOOL)isRetryableClientError:(NSError *)error{
    switch (error.code) {
            // Retry these
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorDataLengthExceedsMaximum:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorHTTPTooManyRedirects:
        case NSURLErrorNotConnectedToInternet:
        case NSURLErrorRedirectToNonExistentLocation:
        case NSURLErrorBadServerResponse:
        case NSURLErrorUserCancelledAuthentication:
        case NSURLErrorUserAuthenticationRequired:
        case NSURLErrorZeroByteResource:
        case NSURLErrorCannotDecodeRawData:
        case NSURLErrorCannotDecodeContentData:
        case NSURLErrorCannotParseResponse:
        case NSURLErrorInternationalRoamingOff:
        case NSURLErrorCallIsActive:
        case NSURLErrorDataNotAllowed:
        case NSURLErrorRequestBodyStreamExhausted:
        case NSURLErrorNoPermissionsToReadFile:
        case NSURLErrorSecureConnectionFailed:
        case NSURLErrorServerCertificateHasBadDate:
        case NSURLErrorServerCertificateUntrusted:
        case NSURLErrorServerCertificateHasUnknownRoot:
        case NSURLErrorServerCertificateNotYetValid:
        case NSURLErrorClientCertificateRejected:
        case NSURLErrorClientCertificateRequired:
        case NSURLErrorCannotLoadFromNetwork:
        case NSURLErrorCannotCreateFile:
        case NSURLErrorCannotOpenFile:
        case NSURLErrorCannotCloseFile:
        case NSURLErrorCannotWriteToFile:
        case NSURLErrorCannotRemoveFile:
        case NSURLErrorCannotMoveFile:
        case NSURLErrorDownloadDecodingFailedMidStream:
        case NSURLErrorDownloadDecodingFailedToComplete:
            return YES;
            
            // Dont Retry these
        case NSURLErrorResourceUnavailable:
        case NSURLErrorFileDoesNotExist:
        case NSURLErrorFileIsDirectory:
            return NO;
            
        default:
            return YES;
    }
    return YES;
}


- (NSError *)createErrorFromHttpResponse:(NSInteger) responseCode
{
    NSError *error = nil;
    if ( responseCode/100 != 2 ) {
        NSString *description  = [NSHTTPURLResponse localizedStringForStatusCode:responseCode];
        error = [NSError errorWithDomain:NSURLErrorDomain code:responseCode userInfo:@{NSLocalizedDescriptionKey: description}];
    }
    return error;
}

//-(NSError *) createNSErrorForCode: (OBFTMErrorCode) code
//{
//    return [NSError errorWithDomain:[OBFTMError errorDomain] code: code userInfo:@{NSLocalizedDescriptionKey:[OBFTMError localizedDescription:code]}];
//}


- (void)deleteFile:(NSString *)key completion:(ANCompletionBlock)aCompletion
{
    AWSS3DeleteObjectRequest *request = [AWSS3DeleteObjectRequest new];
    request.bucket = self.bucket;
    request.key = key;
    
    [[[AWSS3 S3ForKey:AWSS3Key] deleteObject:request] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
        aCompletion(task.error);
        return nil;
    }];
}

#pragma mark Updating credentials

- (void)updateCredentials {
    
    [self _updateCredentialsIfPossible];
    
    [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {
        [self _updateCredentialsIfPossible];
    } error:^(NSError *error) {
        [self _loadS3CredentialsDidFailWithError:error];
    }];
}

- (void)_loadS3CredentialsDidFailWithError:(NSError *)error
{
    ANDispatchBlockToMainQueue(^{
        NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
        NSString* badConnectiontitle = [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", [NSObject an_safeString:appName]];

        UIAlertView *av = [[UIAlertView alloc]
                initWithTitle:@"Bad Connection"
                      message:badConnectiontitle
                     delegate:nil
            cancelButtonTitle:@"Try Again"
            otherButtonTitles:nil];

        [av.rac_buttonClickedSignal subscribeNext:^(id x) {
            [self updateCredentials];
        }];
        [av show];
    });

}

- (void)_updateCredentialsIfPossible
{
    if (!ANIsEmpty([ZZKeychainDataProvider loadCredentials].bucket)) {
        [self _updateCredentials];
    }
}

- (void)_updateCredentials
{
    ZZS3CredentialsDomainModel* credentials = [ZZKeychainDataProvider loadCredentials];
    AWSServiceConfiguration *configuration = [self _configurationWithCredentialsModel:credentials];
    
    self.bucket = credentials.bucket;
    
    //TODO: Make sure no connections
    [AWSS3 removeS3ForKey:AWSS3Key];
    [AWSS3TransferUtility removeS3TransferUtilityForKey:AWSS3Key];
    
    [AWSS3 registerS3WithConfiguration:configuration forKey:AWSS3Key];
    [AWSS3TransferUtility registerS3TransferUtilityWithConfiguration:configuration forKey:AWSS3Key];
}

- (AWSServiceConfiguration *)_configurationWithCredentialsModel:(ZZS3CredentialsDomainModel *)credentialsModel
{
    AWSRegionType type = credentialsModel.regionType;

    AWSStaticCredentialsProvider *provider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:credentialsModel.accessKey secretKey:credentialsModel.secretKey];

    return [[AWSServiceConfiguration alloc] initWithRegion:type credentialsProvider:provider];
}

@end