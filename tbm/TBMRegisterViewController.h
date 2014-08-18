//
//  TBMRegisterViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 7/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMRegisterProtocol.h"

@interface TBMRegisterViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
    @property (nonatomic) id <TBMRegisterProtocol> delegate;
    @property UIAlertView *getUsersErrorAlert;
    @property (weak, nonatomic) IBOutlet UITextField *mobileNumber;
    - (IBAction)didEnterMobileNumber:(UITextField *)sender;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
    @property BOOL isWaiting;
@end
