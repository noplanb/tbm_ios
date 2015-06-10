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
static const float LayoutConstNameLabelHeight = 22;
static const float LayoutConstNameLabelMargin = 5;
static const float LayoutConstNameLabelFontSize = 0.55 * LayoutConstNameLabelHeight;
static const float LayoutConstBorderWidth = 2.5;
static const float LayoutConstCountWidth = 22;
static const float LayoutConstUnviewedCountFontSize = 0.5 * LayoutConstCountWidth;
static const float LayoutConstIndicatorMaxWidth = 40;
static const float LayoutConstIndicatorFractionalWidth = 0.15;
static const float LayoutConstNoThumbButtonsMargin = 2;
static const float LayoutConstNoThumbFontSize = 15;
static const float LayoutConstUploadingBarHeight = LayoutConstNoThumbButtonsMargin;


@interface TBMGridElementViewController : UIViewController <TBMVideoStatusNotificationProtocol, TBMVideoPlayerEventNotification>
- (instancetype)initWithIndex:(NSInteger)index;
- (void)gridDidChange:(NSInteger)index;
@end
