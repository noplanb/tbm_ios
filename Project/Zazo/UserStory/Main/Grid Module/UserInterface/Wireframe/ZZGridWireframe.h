//
//  ZZGridWireframe.h
//  Versoos
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsWireframe.h"
#import "ANMessageDomainModel.h"

@class ZZGridPresenter;
@class ZZMainWireframe;

@interface ZZGridWireframe : NSObject

@property (nonatomic, strong) ZZMainWireframe *mainWireframe;
@property (nonatomic, strong, readonly) ZZGridPresenter *presenter;
@property (nonatomic, strong, readonly) UIViewController *gridController;

#pragma mark - Details

- (void)presentSMSDialogWithModel:(ANMessageDomainModel *)model
                          success:(ANCodeBlock)success
                             fail:(ANCodeBlock)fail;

- (void)presentSharingDialogWithModel:(ANMessageDomainModel *)model
                              success:(ANCodeBlock)success
                                 fail:(ANCodeBlock)fail;

- (void)presentTranscriptionForUserWithID:(NSString *)friendID;
- (void)presentComposeForUserWithID:(NSString *)friendID;

@end
