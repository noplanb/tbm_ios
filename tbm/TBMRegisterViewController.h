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

@interface TBMRegisterViewController : UIViewController <TBMFriendGetterCallback>
@property BOOL isWaiting;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTxt;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberTxt;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)submit:(UIButton *)sender;

@end
