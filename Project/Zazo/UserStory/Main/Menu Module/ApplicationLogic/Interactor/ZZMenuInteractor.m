//
//  ZZMenuInteractor.m
//  Zazo
//

#import "ZZMenuInteractor.h"
#import "ZZMenu.h"
#import "ZZUserDomainModel.h"
#import "ZZUserDataProvider.h"

@implementation ZZMenuInteractor

- (NSString *)username
{
    ZZUserDomainModel *user = [ZZUserDataProvider authenticatedUser];
    return user.fullName;
}


@end
