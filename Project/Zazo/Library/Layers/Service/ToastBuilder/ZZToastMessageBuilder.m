//
//  ZZMessageManager.m
//
//  Created by ANODA on 14/12/14.
//
//

#import "ZZToastMessageBuilder.h"
#import "JFMinimalNotification.h"

@interface ZZToastMessageBuilder () <JFMinimalNotificationDelegate>

@property (nonatomic, strong) JFMinimalNotification* minimalNotification;

@end

@implementation ZZToastMessageBuilder

- (void)showToastWithMessage:(NSString*)message
{
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:@"Unlock another feature!"
                                                                   subTitle:message dismissalDelay:0.0 touchHandler:^{
                                                                       [self.minimalNotification dismiss];
                                                                   }];
    self.minimalNotification.subTitleLabel.numberOfLines = 0;
    self.minimalNotification.subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.minimalNotification.delegate = self;
    [self.minimalNotification setTitleFont:[UIFont an_regularFontWithSize:15]];
    [self.minimalNotification setSubTitleFont:[UIFont an_regularFontWithSize:15]];
    [self.minimalNotification.subTitleLabel sizeToFit];
    
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:self.minimalNotification];

    [self.minimalNotification show];
    
    ANDispatchBlockAfter(4.0, ^{
        [self.minimalNotification dismiss];
    });
}

#pragma mark - JFMinimalNotificationDelegate

- (void)minimalNotificationWillShowNotification:(JFMinimalNotification*)notification
{
    [self.delegate toastMessageWillShow];
}

- (void)minimalNotificationDidShowNotification:(JFMinimalNotification*)notification
{
    [self.delegate toastMessageDidShow];
}

- (void)minimalNotificationWillDisimissNotification:(JFMinimalNotification*)notification
{
    [self.delegate toastMessageWillDismiss];
}

- (void)minimalNotificationDidDismissNotification:(JFMinimalNotification*)notification
{
    [self.delegate toastMessageDidDismiss];
}


@end
