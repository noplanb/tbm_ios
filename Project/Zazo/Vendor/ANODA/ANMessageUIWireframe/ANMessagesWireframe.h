//
//  ANEmailPresenter.h
//  Zazo
//
//  Created by ANODA on 1/23/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ANMessageDomainModel;
@import MessageUI;

static NSInteger const kApplicationCannotSendMessage = -10002;

typedef void(^ANMessageCompletionBlock)(MessageComposeResult result);
typedef void(^ANEmailCompletionBlock)(MFMailComposeResult result);
typedef void(^ZZSharingCompletionBlock)(BOOL completed);

@interface ANMessagesWireframe : NSObject

- (void)presentEmailControllerFromViewController:(UIViewController*)vc
                                       withModel:(ANMessageDomainModel*)model
                                      completion:(ANEmailCompletionBlock)completion;

- (void)presentMessageControllerFromViewController:(UIViewController*)vc
                                         withModel:(ANMessageDomainModel*)model
                                        completion:(ANMessageCompletionBlock)completion;

- (void)presentSharingControllerFromViewController:(UIViewController*)vc
                                         withModel:(ANMessageDomainModel*)model
                                        completion:(ZZSharingCompletionBlock)completion;


@end
