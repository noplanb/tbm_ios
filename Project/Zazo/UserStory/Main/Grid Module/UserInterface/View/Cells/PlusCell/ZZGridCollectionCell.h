//
//  ZZGridCollectionCell.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANCollectionViewCell.h"
#import "ZZGridBaseCell.h"

@interface ZZGridCollectionCell : ZZGridBaseCell

- (UIImage*)actualSateImage;
- (void)makeActualScreenShoot;
- (void)showContainFriendAnimation;
- (void)showUploadVideoAnimationWithCount:(NSInteger)count;

- (void)videoDownloadedWithUrl:(NSURL *)videoUrl;
- (void)stopVideoPlaying;
- (void)startVidePlay;

@end
