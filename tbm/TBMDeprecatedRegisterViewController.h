//
//  TBMRegisterViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 7/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBMDeprecatedRegisterViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
    @property UIAlertView *getUsersErrorAlert;



    @property (weak, nonatomic) IBOutlet UITextField *mobileNumber;
    - (IBAction)didEnterMobileNumber:(UITextField *)sender;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
    @property BOOL isWaiting;
@end
