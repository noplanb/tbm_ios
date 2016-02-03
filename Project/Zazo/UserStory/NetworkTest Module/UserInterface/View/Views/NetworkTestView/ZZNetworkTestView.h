//
//  ZZNetworkTestView.h
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZZNetworkTestView : UIView

@property (nonatomic, strong) UILabel* statusLabel;
@property (nonatomic, strong) UILabel* triesLabel;

@property (nonatomic, strong) UILabel* uploadVideoCountLabel;
@property (nonatomic, strong) UILabel* downloadVideoCountLabel;
@property (nonatomic, strong) UILabel* completedCountLabel;

@property (nonatomic, strong) UILabel* failedUploadLabel;
@property (nonatomic, strong) UILabel* failedDownloadLabel;

@property (nonatomic, strong) UILabel* currentLabel;

@property (nonatomic, strong) UILabel* statusVideoLabel;

@property (nonatomic, strong) UILabel* retryLabel;

@property (nonatomic, strong) UIButton* startButton;
@property (nonatomic, strong) UIButton* resetRetriesButton;
@property (nonatomic, strong) UIButton* resetStatsButton;

@property (nonatomic, strong) NSString *headerTitle;

@end
