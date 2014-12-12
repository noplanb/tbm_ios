//
//  TBMGridElementViewController.h
//  tbm
//
//  Created by Sani Elfishawy on 12/9/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMFriend.h"
#import "TBMVideoPlayer.h"

@interface TBMGridElementViewController : UIViewController <TBMVideoStatusNotificationProtocol, TBMVideoPlayerEventNotification>
- (instancetype)initWithIndex:(NSInteger)index;
- (void)gridDidChange:(NSInteger)index;
@end
