
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


@interface ZZFakeRotationCell : UIView
@property(nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSNumber* index;
@property (nonatomic, strong) NSIndexPath* indexPath;
@property (nonatomic, strong) UIImageView* stateImageView;
-(void) tapped;
-(void) longTapStarted;
-(void) longTapEnded;
- (void)updateBadgeWithNumber:(NSNumber*)number;

@end