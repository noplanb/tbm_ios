//
//  ZZSecretSwitchServerCell.m
//  Zazo
//
//  Created by ANODA on 8/29/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretSegmentCell.h"

@interface ZZSecretSegmentCell ()

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) ZZSecretSegmentCellViewModel *model;

@end

@implementation ZZSecretSegmentCell

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

- (void)updateWithModel:(ZZSecretSegmentCellViewModel *)model
{
    self.model = model;
    if (!self.segmentControl.numberOfSegments)
    {
        [model.titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.segmentControl insertSegmentWithTitle:obj atIndex:idx animated:NO];
        }];
    }
    self.segmentControl.selectedSegmentIndex = model.selectedIndex;
}

- (void)_selectedValueUpdated:(UISegmentedControl *)sender
{
    [self.model updateSelectedValueTo:sender.selectedSegmentIndex];
}


#pragma mark - Lazy Load

- (UISegmentedControl *)segmentControl
{
    if (!_segmentControl)
    {
        _segmentControl = [UISegmentedControl new];
        [_segmentControl addTarget:self action:@selector(_selectedValueUpdated:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_segmentControl];

        [_segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(5);
            make.bottom.right.equalTo(self.contentView).offset(-5);
        }];
    }
    return _segmentControl;
}

@end
