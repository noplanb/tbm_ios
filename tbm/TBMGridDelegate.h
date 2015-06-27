//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMGridDelegate <NSObject>
- (void)gridDidAppear:(TBMGridViewController *)gridViewController;
-(void)videoPlayerDidStartPlaying:(TBMVideoPlayer *)player;
-(void)videoPlayerDidStopPlaying:(TBMVideoPlayer *)player;
-(void)messageDidUpload;
-(void)messageDidViewed:(NSUInteger)gridIndex;
-(void)messageDidReceive;
-(void)friendDidAdd;
@end