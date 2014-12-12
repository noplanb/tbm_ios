//
//  TBMHomeViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMGridViewController.h"


@interface TBMHomeViewController : UIViewController

@property (strong, nonatomic) UIAlertView *versionHandlerAlert;
@property (nonatomic) TBMGridViewController *gridViewController;
@end
