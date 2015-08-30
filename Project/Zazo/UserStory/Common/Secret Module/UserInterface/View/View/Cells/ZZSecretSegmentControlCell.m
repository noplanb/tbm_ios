//
//  ZZSecretSegmentControlCell.m
//  Zazo
//
//  Created by ANODA on 8/29/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretSegmentControlCell.h"

static UIEdgeInsets const kSegmentControlInsets = {5, 5, 5, 5};

@implementation ZZSecretSegmentControlCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self segmentControl];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (UISegmentedControl *)segmentControl
{
    if (!_segmentControl)
    {
        NSArray* items = @[NSLocalizedString(@"secret-controller.rollbar.segment-control.title", nil),
                           NSLocalizedString(@"secret-controller.server.segment-control.title", nil)];
        _segmentControl = [[UISegmentedControl alloc] initWithItems:items];
        _segmentControl.selectedSegmentIndex = 0;
        [self.contentView addSubview:_segmentControl];
        
        [_segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(kSegmentControlInsets);
        }];
    }
    return _segmentControl;
}

@end
