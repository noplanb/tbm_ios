//
//  ZZNetworkTestVC.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestVC.h"
#import "ZZNetworkTestView.h"

@interface ZZNetworkTestVC ()

@property (nonatomic, strong) ZZNetworkTestView* networkTestView;

@end

@implementation ZZNetworkTestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ZZColorTheme shared].gridBackgourndColor;
    [self _setupStartStopButton];
}

- (void)loadView
{
    self.view = self.networkTestView;
}


#pragma mark - View interface

- (void)outgoingVideoChangeWithCount:(NSInteger)count
{
    ANDispatchBlockToMainQueue(^{
        self.networkTestView.uploadVideoCountLabel.text = [NSString stringWithFormat:@"%@%i",@"\u2191",count];
    });
}

- (void)updateCurrentStatus:(NSString *)status
{
    ANDispatchBlockToMainQueue(^{
        self.networkTestView.currentLabel.text = status;
    });
}

- (void)completedVideoChangeWithCounter:(NSInteger)count
{
    ANDispatchBlockToMainQueue(^{
        self.networkTestView.completedCountLabel.text = [NSString stringWithFormat:@"%@ %i",@"\u2297",count];
    });
}

- (void)failedOutgoingVideoWithCounter:(NSInteger)count
{
    ANDispatchBlockToMainQueue(^{
        self.networkTestView.failedUploadLabel.text = [NSString stringWithFormat:@"%@%i",@"\u21e1",count];
    });
}

#pragma mark - Setup Buttons

- (void)_setupStartStopButton
{
    self.networkTestView.startButton.rac_command = [RACCommand commandWithBlock:^{
        
        self.networkTestView.startButton.selected = !self.networkTestView.startButton.selected;
        
        if (self.networkTestView.startButton.selected)
        {
            [self.eventHandler startNetworkTest];
        }
        else
        {
            [self.eventHandler stopNetworkTest];
        }
    }];
}


#pragma mark - Private

- (ZZNetworkTestView *)networkTestView
{
    if (!_networkTestView)
    {
        _networkTestView = [ZZNetworkTestView new];
    }
    
    return _networkTestView;
}

@end
