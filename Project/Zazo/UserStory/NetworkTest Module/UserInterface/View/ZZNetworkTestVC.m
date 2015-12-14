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
@property (nonatomic, assign) BOOL isLoadingSate;

@end

@implementation ZZNetworkTestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ZZColorTheme shared].gridBackgourndColor;
    [self _setupStartStopButton];
    [self _setupResetStatsButton];
    [self _setupResetRetriesButton];
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

- (void)incomingVideoChangeWithCount:(NSInteger)count
{
    ANDispatchBlockToMainQueue(^{
        self.networkTestView.downloadVideoCountLabel.text = [NSString stringWithFormat:@"%@%i",@"\u2193",count];
    });
}

- (void)failedIncomingVideoWithCounter:(NSInteger)count
{
    ANDispatchBlockToMainQueue(^{
       self.networkTestView.failedDownloadLabel.text = [NSString stringWithFormat:@"%@%i",@"\u21e3",count];
    });
}

- (void)updateTriesCount:(NSInteger)count
{
    ANDispatchBlockToMainQueue(^{
        self.networkTestView.triesLabel.text = [NSString stringWithFormat:@"%i",count];
    });
}

- (void)updateVideoSatus:(NSString *)status
{
    ANDispatchBlockToMainQueue(^{
        self.networkTestView.statusVideoLabel.text = status;
    });
}

- (void)updateRetryCount:(NSInteger)count
{
    ANDispatchBlockToMainQueue(^{
        self.networkTestView.retryLabel.text = [NSString stringWithFormat:@"%i",count];
    });
}

#pragma mark - Setup Buttons

- (void)_setupStartStopButton
{
    self.networkTestView.startButton.rac_command = [RACCommand commandWithBlock:^{
        
        self.networkTestView.startButton.selected = !self.networkTestView.startButton.selected;
        self.networkTestView.resetStatsButton.enabled = !self.networkTestView.startButton.selected;
        if (self.networkTestView.startButton.selected)
        {
            [self _updateToStartedState];
            [self.eventHandler startNetworkTest];
        }
        else
        {
            [self _updateToStoppedState];
            [self.eventHandler stopNetworkTest];
        }
    }];
}

- (void)_setupResetStatsButton
{
    self.networkTestView.resetStatsButton.rac_command = [RACCommand commandWithBlock:^{
        [self.eventHandler resetStats];
        [self _updateCurrentStatusToWaiting];
        [self _updateVideoStatusToNew];
    }];
}

- (void)_setupResetRetriesButton
{
    self.networkTestView.resetRetriesButton.rac_command = [RACCommand commandWithBlock:^{
        [self.eventHandler resetRetries];
    }];
}

#pragma mark - Private

- (void)_updateToStartedState
{
    self.networkTestView.statusLabel.text = NSLocalizedString(@"network-test-view.status.started", nil);
}

- (void)_updateToStoppedState
{
    self.networkTestView.statusLabel.text = NSLocalizedString(@"network-test-view.status.stopped", nil);
    [self _updateVideoStatusToNew];
    [self _updateCurrentStatusToWaiting];
}

- (void)_updateVideoStatusToNew
{
    self.networkTestView.statusVideoLabel.text = NSLocalizedString(@"network-test-view.videostatus.new", nil);
}

- (void)_updateCurrentStatusToWaiting
{
    self.networkTestView.currentLabel.text = NSLocalizedString(@"network-test-view.current.status.waiting", nil);
}

- (ZZNetworkTestView *)networkTestView
{
    if (!_networkTestView)
    {
        _networkTestView = [ZZNetworkTestView new];
    }
    
    return _networkTestView;
}

@end
