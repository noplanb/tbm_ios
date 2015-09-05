
//  Zazo
//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

@interface ZZFakeRotationCell : UIView

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSNumber* index;
@property (nonatomic, strong) NSIndexPath* indexPath;
@property (nonatomic, strong) UIImageView* stateImageView;

- (void)tapped;
- (void)longTapStarted;
- (void)longTapEnded;
- (void)updateBadgeWithNumber:(NSNumber*)number;

@end