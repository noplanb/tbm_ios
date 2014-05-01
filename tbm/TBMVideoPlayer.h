//
//  TBMVideoPlayer.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaPlayer/MediaPlayer.h"

@interface TBMVideoPlayer : NSObject

@property NSNumber *friendId;

@property MPMoviePlayerController *moviePlayerController;
@property NSURL *videoUrl;
@property UIView *playView;

// Class methods
+ (id)createWithView:(UIView *)playView friendId:(NSNumber *)friendId;
+ (id)findWithFriendId:(NSNumber *)friendId;
+ (void)removeWithFriendId:(NSNumber *)friendId;
+ (void)removeAll;


// Instance methods
- (void)togglePlay;
@end
