//
//  TBMHomeViewController+Grid.h
//  tbm
//
//  Created by Sani Elfishawy on 11/11/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"
#import "TBMVideoPlayer.h"

@interface TBMHomeViewController (Grid)
- (void)setupGrid;

- (TBMVideoPlayer *)videoPlayerWithFriend:(TBMFriend *)friend;
- (TBMGridElement *)gridElementWithView:(UIView *)view;
- (TBMVideoPlayer *)videoPlayerWithView:(UIView *)view;
- (void)updateAllGridViews;
- (NSMutableArray *)friendsOnGrid;
- (NSMutableArray *)friendsOnBench;
- (void)moveFriendToGrid:(TBMFriend *)friend;


@end
