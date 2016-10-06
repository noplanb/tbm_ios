//
//  ZZMenuInteractor.m
//  Zazo
//

#import "ZZMenuInteractor.h"
#import "ZZMenu.h"
#import "ZZUserDomainModel.h"
#import "ZZUserDataProvider.h"
#import "ZZCommonModelsGenerator.h"

@interface ZZMenuInteractor ()

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

- (UIImage *)avatar
{
    return [[AvatarStorageService sharedService] get];
}

@end
