//
//  TBMBenchViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 12/16/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMGridViewController.h"

@interface TBMBenchViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic) BOOL isShowing;

+ (TBMBenchViewController *)existingInstance;
- (instancetype)initWithContainerView:(UIView *)containerView gridViewController:(TBMGridViewController *)gridViewController;

- (void)show;
- (void)hide;
- (void)toggle;
@end