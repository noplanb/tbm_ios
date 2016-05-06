//
//  ZZCommonModelsGenerator.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZCommonModelsGenerator.h"
#import "ZZUserDomainModel.h"
#import "ANMessageDomainModel.h"
#import "DeviceUtil.h"

@implementation ZZCommonModelsGenerator

+ (ANMessageDomainModel *)feedbackModelWithUser:(ZZUserDomainModel *)user
{
    ANMessageDomainModel *model = [ANMessageDomainModel new];
    model.title = kApplicationFeedbackEmailSubject;
    model.recipients = @[kApplicationFeedbackEmailAddress];
    model.isHTMLMessage = YES;
    model.message = [NSString stringWithFormat:@"<font color = \"000000\"></br></br></br>---------------------------------</br>iOS: %@</br>Model: %@</br>User mKey: %@</br>App Version: %@</br>Build Version: %@ - %@ </font>", [[UIDevice currentDevice] systemVersion], [DeviceUtil hardwareDescription], user.mkey, [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey], kGlobalApplicationVersion];
    return model;
}

@end
