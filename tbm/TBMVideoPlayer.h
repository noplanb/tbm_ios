//
//  TBMVideoPlayer.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaPlayer/MediaPlayer.h"

#import "TBMFriend.h"

@interface TBMVideoPlayer : NSObject <TBMVideoStatusNotoficationProtocol>

@property NSString *friendId;
@property TBMFriend *friend;
@property MPMoviePlayerController *moviePlayerController;
@property NSURL *videoUrl;
@property UIView *friendView;
@property UIView *playerView;
@property UIImageView *thumbView;
@property CALayer *viewedIndicatorLayer;

// Class methods
+ (id)createWithView:(UIView *)playView friendId:(NSString *)friendId;
+ (id)findWithFriendId:(NSString *)friendId;
+ (void)removeWithFriendId:(NSString *)friendId;
+ (void)removeAll;


// Instance methods
- (void)togglePlay;
@end
