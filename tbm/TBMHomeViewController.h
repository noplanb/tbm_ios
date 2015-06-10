//
//  TBMHomeViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMGridViewController.h"
#import "TBMBenchViewController.h"

@interface TBMHomeViewController : UIViewController <TBMBenchViewControllerDelegate,TBMGridDeleate>

@property (nonatomic) TBMGridViewController *gridViewController;

+ (TBMHomeViewController *)existingInstance;
@end
