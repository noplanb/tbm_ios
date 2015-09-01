//
//  ZZGridCollectionCell.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANCollectionViewCell.h"
#import "ZZGridBaseCell.h"
#import "ZZUserRecorderGridView.h"

@interface ZZGridCollectionCell : ZZGridBaseCell

@property (nonatomic, strong) ZZUserRecorderGridView* recorderView;

- (UIImage*)actualSateImage;
- (void)makeActualScreenShoot;
- (void)showContainFriendAnimation;

@end
