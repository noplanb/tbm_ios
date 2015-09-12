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
typedef void(^ANEmailComletionBlock)(MFMailComposeResult result);

@interface ANMessagesWireframe : NSObject

- (void)presentEmailControllerFromViewController:(UIViewController*)vc
                                       withModel:(ANMessageDomainModel*)model
                                      completion:(ANEmailComletionBlock)completion;

- (void)presentMessageControllerFromViewController:(UIViewController*)vc
                                         withModel:(ANMessageDomainModel*)model
                                        completion:(ANMessageCompletionBlock)completion;

@end
