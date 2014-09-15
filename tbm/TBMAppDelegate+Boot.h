//
//  TBMHomeViewController+Boot.h
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate.h"

@interface TBMAppDelegate (Boot) <UIAlertViewDelegate>
- (void)boot;
- (void)didCompleteRegistration;

@end
