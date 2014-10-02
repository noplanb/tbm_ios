//
//  TBMHomeViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMLongPressTouchHandlerCallback.h"
#import "TBMVideoRecorder.h"
#import "TBMFriend.h"
#import "TBMVersionHandler.h"


@protocol TBMAppDelegateEventNotificationProtocol <NSObject>
- (void)appWillEnterForeground;
- (void)appDidBecomeActive;
@end

@interface TBMHomeViewController : UIViewController <TBMLongPressTouchHandlerCallback, TBMVideoRecorderDelegate, TBMVideoStatusNotificationProtocol, TBMAppDelegateEventNotificationProtocol>
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (strong, nonatomic) UIAlertView *versionHandlerAlert;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *plusLabels;

- (NSMutableArray *)activeFriendViews;
- (NSMutableArray *)inactiveFriendViews;


@end
