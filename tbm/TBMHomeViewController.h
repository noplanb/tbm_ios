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

@interface TBMHomeViewController : UIViewController <TBMLongPressTouchHandlerCallback, TBMVideoRecorderDelegate, TBMVideoStatusNotificationProtocol>
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (strong, nonatomic) UIAlertView *versionHandlerAlert;

@end
