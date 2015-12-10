//
//  ZZNetworkTestView.m
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNetworkTestView.h"
#import "ZZNetworkTestHeaderView.h"
#import "ZZNetworkTestViewUiConstants.h"

@interface ZZNetworkTestView ()

@property (nonatomic, strong) UILabel* statusTitleLabel;
@property (nonatomic, strong) UILabel* triesTitileLabel;
@property (nonatomic, strong) UILabel* failedTitleLabel;
@property (nonatomic, strong) UILabel* currentTitleLabel;
@property (nonatomic, strong) UILabel* statusVideoTitleLabel;
@property (nonatomic, strong) UILabel* retryTitleLabel;

@property (nonatomic, strong) ZZNetworkTestHeaderView* headerView;

@end

@implementation ZZNetworkTestView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self headerView];
        [self statusTitleLabel];
        [self statusLabel];
        [self triesTitileLabel];
        [self triesLabel];
        
        [self uploadVideoCountLabel];
        [self downloadVideoCountLabel];
        [self completedCountLabel];
        
        [self failedTitleLabel];
        [self failedUploadLabel];
        [self failedDownloadLabel];
        
        [self currentTitleLabel];
        [self currentLabel];
        
        [self statusVideoTitleLabel];
        [self statusVideoLabel];
        
        [self retryTitleLabel];
        [self retryLabel];
        
        [self startButton];
        [self resetRetriesButton];
        [self resetStatsButton];
        
    }
    return self;
}

- (ZZNetworkTestHeaderView *)headerView
{
    if (!_headerView)
    {
        _headerView = [ZZNetworkTestHeaderView new];
        [self addSubview:_headerView];
        
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@(kNetworkTestHeaderViewHeight()));
        }];
    }
    
    return _headerView;

}


#pragma mark - Info part


#pragma mark - Status

- (UILabel*)statusTitleLabel
{
    if (!_statusTitleLabel)
    {
        _statusTitleLabel = [UILabel new];
        [_statusTitleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _statusTitleLabel.textColor = [UIColor whiteColor];
        _statusTitleLabel.textAlignment = NSTextAlignmentRight;
        _statusTitleLabel.text = NSLocalizedString(@"network-test-view.status.title", nil);
        [self addSubview:_statusTitleLabel];
        
        [_statusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self.headerView.mas_bottom).offset(kStatusTitleTopOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _statusTitleLabel;
}

- (UILabel*)statusLabel
{
    if (!_statusLabel)
    {
        _statusLabel = [UILabel new];
        _statusLabel.textColor = [UIColor whiteColor];
        [_statusLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _statusLabel.text = NSLocalizedString(@"network-test-view.status.stopped", nil);;
        [self addSubview:_statusLabel];
        
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.statusTitleLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.top.equalTo(self.headerView.mas_bottom).offset(kStatusTitleTopOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _statusLabel;
}


#pragma mark - Tries

- (UILabel*)triesTitileLabel
{
    if (!_triesTitileLabel)
    {
        _triesTitileLabel = [UILabel new];
        _triesTitileLabel.textColor = [UIColor whiteColor];
        _triesTitileLabel.text = NSLocalizedString(@"network-test-view.tries.title", nil);
        [_triesTitileLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _triesTitileLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_triesTitileLabel];
        
        [_triesTitileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kInfoLeftOffset());
            make.top.equalTo(self.statusTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _triesTitileLabel;
}

- (UILabel*)triesLabel
{
    if (!_triesLabel)
    {
        _triesLabel = [UILabel new];
        _triesLabel.textColor = [UIColor whiteColor];
        _triesLabel.text = @"0";
        [_triesLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        [self addSubview:_triesLabel];
        
        [_triesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.triesTitileLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.top.equalTo(self.statusTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _triesLabel;
}


#pragma mark - Upload/Download indication

- (UILabel*)uploadVideoCountLabel
{
    if (!_uploadVideoCountLabel)
    {
        _uploadVideoCountLabel = [UILabel new];
        _uploadVideoCountLabel.textColor = [UIColor whiteColor];
        _uploadVideoCountLabel.text = [NSString stringWithFormat:@"%@%@",@"\u2191",@"0"];
        [_uploadVideoCountLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        [self addSubview:_uploadVideoCountLabel];
        
        [_uploadVideoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kInfoLeftOffset());
            make.top.equalTo(self.triesTitileLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
        }];
    }
    
    return _uploadVideoCountLabel;
}

- (UILabel*)downloadVideoCountLabel
{
    if (!_downloadVideoCountLabel)
    {
        _downloadVideoCountLabel = [UILabel new];
        _downloadVideoCountLabel.textColor = [UIColor whiteColor];
        _downloadVideoCountLabel.text = [NSString stringWithFormat:@"%@%@",@"\u2193",@"0"];
        [_downloadVideoCountLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        [self addSubview:_downloadVideoCountLabel];
        
        [_downloadVideoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.uploadVideoCountLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.top.equalTo(self.triesTitileLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
        }];
    }
    
    return _downloadVideoCountLabel;
}

- (UILabel*)completedCountLabel
{
    if (!_completedCountLabel)
    {
        _completedCountLabel = [UILabel new];
        _completedCountLabel.textColor = [UIColor whiteColor];
        _completedCountLabel.text = [NSString stringWithFormat:@"%@ %@",@"\u2297",@"0"];
        [_completedCountLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        [self addSubview:_completedCountLabel];
        
        [_completedCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.downloadVideoCountLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.top.equalTo(self.triesTitileLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
        }];
    }
    
    return _completedCountLabel;
}


#pragma mark - Failed part

- (UILabel*)failedTitleLabel
{
    if (!_failedTitleLabel)
    {
        _failedTitleLabel = [UILabel new];
        _failedTitleLabel.textColor = [UIColor whiteColor];
        [_failedTitleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _failedTitleLabel.text = NSLocalizedString(@"network-test-view.failed.title", nil);
        [self addSubview:_failedTitleLabel];
        
        [_failedTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.uploadVideoCountLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self).offset(kInfoLeftOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _failedTitleLabel;
}

- (UILabel*)failedUploadLabel
{
    if (!_failedUploadLabel)
    {
        _failedUploadLabel = [UILabel new];
        _failedUploadLabel.textColor = [UIColor whiteColor];
        [_failedUploadLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _failedUploadLabel.text = [NSString stringWithFormat:@"%@%@",@"\u21e1",@"0"];
        [self addSubview:_failedUploadLabel];
        
        [_failedUploadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.uploadVideoCountLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self.failedTitleLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _failedUploadLabel;
}

- (UILabel*)failedDownloadLabel
{
    if (!_failedDownloadLabel)
    {
        _failedDownloadLabel = [UILabel new];
        _failedDownloadLabel.textColor = [UIColor whiteColor];
        [_failedDownloadLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _failedDownloadLabel.text = [NSString stringWithFormat:@"%@%@",@"\u21e3",@"0"];
        [self addSubview:_failedDownloadLabel];
        
        [_failedDownloadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.uploadVideoCountLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self.failedUploadLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _failedDownloadLabel;
}


#pragma mark - Current

- (UILabel*)currentTitleLabel
{
    if (!_currentTitleLabel)
    {
        _currentTitleLabel = [UILabel new];
        _currentTitleLabel.textColor = [UIColor whiteColor];
        _currentTitleLabel.numberOfLines = 0;
        [_currentTitleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _currentTitleLabel.text = NSLocalizedString(@"network-test-view.current.title", nil);
        [self addSubview:_currentTitleLabel];
        
        [_currentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.failedTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self).offset(kInfoLeftOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _currentTitleLabel;
}

- (UILabel*)currentLabel
{
    if (!_currentLabel)
    {
        _currentLabel = [UILabel new];
        _currentLabel.textColor = [UIColor whiteColor];
        _currentLabel.text = NSLocalizedString(@"network-test-view.current.status.waiting", nil);
        [_currentLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        [self addSubview:_currentLabel];
        
        [_currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.failedTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self.currentTitleLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _currentLabel;
}


#pragma mark - Status

- (UILabel*)statusVideoTitleLabel
{
    if (!_statusVideoTitleLabel)
    {
        _statusVideoTitleLabel = [UILabel new];
        _statusVideoTitleLabel.textColor = [UIColor whiteColor];
        [_statusVideoTitleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _statusVideoTitleLabel.text = NSLocalizedString(@"network-test-view.status.video.title", nil);
        [self addSubview:_statusVideoTitleLabel];
        
        [_statusVideoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.currentTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self).offset(kInfoLeftOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _statusVideoTitleLabel;
}

- (UILabel*)statusVideoLabel
{
    if (!_statusVideoLabel)
    {
        _statusVideoLabel = [UILabel new];
        _statusVideoLabel.textColor = [UIColor whiteColor];
        [_statusVideoLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _statusVideoLabel.text = NSLocalizedString(@"network-test-view.videostatus.new", nil);
        [self addSubview:_statusVideoLabel];
        
        [_statusVideoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.currentTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self.statusVideoTitleLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _statusVideoLabel;
}


#pragma mark - Retry

- (UILabel*)retryTitleLabel
{
    if (!_retryTitleLabel)
    {
        _retryTitleLabel = [UILabel new];
        _retryTitleLabel.textColor = [UIColor whiteColor];
        [_retryTitleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _retryTitleLabel.text = NSLocalizedString(@"network-test-view.retry.title", nil);
        [self addSubview:_retryTitleLabel];
        
        [_retryTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.statusVideoTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self).offset(kInfoLeftOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _retryTitleLabel;
}

- (UILabel*)retryLabel
{
    if (!_retryLabel)
    {
        _retryLabel = [UILabel new];
        _retryLabel.textColor = [UIColor whiteColor];
        [_retryLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
        _retryLabel.text = @"0";
        [self addSubview:_retryLabel];
        
        [_retryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.statusVideoTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self.retryTitleLabel.mas_right).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestLabelSize().height));
        }];
    }
    
    return _retryLabel;
}


#pragma mark - Buttons

- (UIButton*)startButton
{
    if (!_startButton)
    {
        _startButton = [UIButton new];
        _startButton.titleLabel.textColor = [UIColor whiteColor];
        _startButton.titleLabel.font = [UIFont an_regularFontWithSize:16];
        _startButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _startButton.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        [_startButton setTitle:NSLocalizedString(@"network-test-view.start.button.title", nil) forState:UIControlStateNormal];
        [self addSubview:_startButton];
        [_startButton setTitle:NSLocalizedString(@"network-test-view.stop.button.titile", nil) forState:UIControlStateSelected];
        
        [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.retryTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestButtonHeight()));
            make.width.equalTo(@(kNetworkTestButtonWidth()-kBetweenInfoLabelOffset()));
        }];
    }
    return _startButton ;
}

- (UIButton*)resetRetriesButton
{
    if (!_resetRetriesButton)
    {
        _resetRetriesButton = [UIButton new];
        _resetRetriesButton.titleLabel.textColor = [UIColor whiteColor];
        _resetRetriesButton.titleLabel.font = [UIFont an_regularFontWithSize:16];
        _resetRetriesButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _resetRetriesButton.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        [_resetRetriesButton setTitle:NSLocalizedString(@"network-test-view.reset.retries.button.title", nil) forState:UIControlStateNormal];
        [self addSubview:_resetRetriesButton];
        
        [_resetRetriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.retryTitleLabel.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.equalTo(self.startButton.mas_right).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestButtonHeight()));
            make.right.equalTo(self).offset(-kBetweenInfoLabelOffset());
        }];
    }
    return _resetRetriesButton ;
}

- (UIButton*)resetStatsButton
{
    if (!_resetStatsButton)
    {
        _resetStatsButton = [UIButton new];
        _resetStatsButton.titleLabel.textColor = [UIColor whiteColor];
        _resetStatsButton.titleLabel.font = [UIFont an_regularFontWithSize:16];
        _resetStatsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _resetStatsButton.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        [_resetStatsButton setTitle:NSLocalizedString(@"network-test-view.reset.stats.button.title", nil) forState:UIControlStateNormal];
        [self addSubview:_resetStatsButton];
        
        [_resetStatsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.startButton.mas_bottom).offset(kBetweenInfoLabelOffset());
            make.left.right.equalTo(self).offset(kBetweenInfoLabelOffset());
            make.height.equalTo(@(kNetworkTestButtonHeight()));
            make.right.equalTo(self).offset(-kBetweenInfoLabelOffset());
        }];
    }
    return _resetStatsButton ;
}

@end
