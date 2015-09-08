//
//  ZZGridCollectionCell.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANCollectionViewCell.h"
#import "ZZGridCellViewModel.h"

@interface ZZGridCell : ANCollectionViewCell

- (void)showContainFriendAnimation;
- (void)showUploadVideoAnimationWithCount:(NSInteger)count;

@end
