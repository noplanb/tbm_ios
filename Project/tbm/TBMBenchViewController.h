//
//  TBMBenchViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 12/16/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMGridViewController.h"

@protocol TBMBenchViewControllerDelegate;

@interface TBMBenchViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic) BOOL isShowing;
@property (nonatomic, weak) id<TBMBenchViewControllerDelegate> delegate;

+ (TBMBenchViewController *)existingInstance;
- (instancetype)initWithContainerView:(UIView *)containerView gridViewController:(TBMGridViewController *)gridViewController;

- (void)show;
- (void)hide;
- (void)toggle;

@end

@protocol TBMBenchViewControllerDelegate <NSObject>

- (void)TBMBenchViewController:(TBMBenchViewController *)vc toggledHidden:(BOOL)isHidden;

@end