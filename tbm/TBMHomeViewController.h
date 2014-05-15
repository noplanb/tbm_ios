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

@interface TBMHomeViewController : UIViewController <TBMLongPressTouchHandlerCallback, TBMVideoRecorderDelegate, TBMVideoStatusNotoficationProtocol>
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;

@end
