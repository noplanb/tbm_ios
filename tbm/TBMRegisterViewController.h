//
//  TBMRegisterViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 11/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TBMFriendGetter.h"
#import "TBMRegisterForm.h"

@interface TBMRegisterViewController : UIViewController <TBMFriendGetterCallback, TBMRegisterFormDelegate>
@property BOOL isWaiting;

@end
