//
//  TBMHomeViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController.h"
#import "TBMHomeViewController+Boot.h"
#import "TBMLongPressTouchHandler.h"
#import "TBMVideoRecorder.h"
#import "TBMVideoPlayer.h"
#import "TBMFriend.h"
#import <UIKit/UIKit.h>

@interface TBMHomeViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *friendViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *friendLabels;
@property TBMLongPressTouchHandler *longPressTouchHandler;
@property TBMVideoRecorder *videoRecorder;
@property TBMVideoPlayer *videoPlayer;
@property BOOL isPlaying;
@end

static NSInteger TBM_HOME_FRIEND_VIEW_INDEX_OFFSET = 10;
static NSInteger TBM_HOME_FRIEND_LABEL_INDEX_OFFSET = 20;

@implementation TBMHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil obbundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self boot];
    [self setupFriendViews];
    
    _longPressTouchHandler = [[TBMLongPressTouchHandler alloc] initWithTargetViews:_friendViews instantiator:self];
    
    NSError * error;
    _videoRecorder = [[TBMVideoRecorder alloc] initWithPreivewView:_centerView error:&error];
    [self hideRecordingIndicator];
    if (!_videoRecorder){
        DebugLog(@"%@", error);
    }
    
    [self setupVideoPlayers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) setupVideoPlayers
{
    [TBMVideoPlayer removeAll];
    for (TBMFriend *friend in [TBMFriend all]){
        UIView *playerView = [self friendViewWithViewIndex:friend.viewIndex];
        [TBMVideoPlayer createWithView:playerView friendId:friend.idTbm];
    }
}

- (void)setupFriendViews
{
    for (TBMFriend *friend in [TBMFriend all]){
        UILabel *label = [self friendLabelWithViewIndex:friend.viewIndex];
        label.text = friend.firstName;
    }
}

- (UIView *)friendViewWithViewIndex:(NSNumber *)viewIndex
{
    if (!viewIndex)
        return nil;
    
    NSInteger tag = [viewIndex integerValue];
    tag += TBM_HOME_FRIEND_VIEW_INDEX_OFFSET;
    for (UIView *view in self.friendViews) {
        if (view.tag == tag){
            return view;
        }
    }
    return nil;
}

- (UILabel *)friendLabelWithViewIndex:(NSNumber *)viewIndex
{
    NSInteger tag = [viewIndex integerValue];
    tag += TBM_HOME_FRIEND_LABEL_INDEX_OFFSET;
    for (UILabel *label in self.friendLabels){
        if (label.tag == tag){
            return label;
        }
    }
    return nil;
}

- (TBMFriend *)friendWithViewTag:(NSUInteger)tag
{
    return [TBMFriend findWithViewIndex:@(tag-TBM_HOME_FRIEND_VIEW_INDEX_OFFSET)];
}


//------------------------------------------
// Longpress touch handling for friend views
//------------------------------------------
// We detect the touches for the entire window using this view controller but pass them to the longPressTouchHandler.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil) {
        [self.longPressTouchHandler touchesMoved:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil){
        [self.longPressTouchHandler touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.longPressTouchHandler != nil){
        [self.longPressTouchHandler touchesCancelled:touches withEvent:event];
    }
}

// Callbacks per the TBMLongPressTouchHandlerCallback protocol.
- (void)LPTHClickWithTargetView:(UIView *)view{
    DebugLog(@"TBMHomeViewController: LPTH: click %ld", (long)view.tag);
    TBMFriend *friend = [self friendWithViewTag:view.tag];
    [(TBMVideoPlayer *)[TBMVideoPlayer findWithFriendId:friend.idTbm] togglePlay];
}

- (void)LPTHStartLongPressWithTargetView:(UIView *)view{
    DebugLog(@"TBMHomeViewController: LPTH: startLongPress %ld", (long)view.tag);
    TBMFriend *friend = [self friendWithViewTag:view.tag];
    [_videoRecorder startRecordingWithFriendId:friend.idTbm];
    [self showRecordingIndicator];
}

- (void)LPTHEndLongPressWithTargetView:(UIView *)view{
    DebugLog(@"TBMHomeViewController: LPTH:  endLongPressed %ld", (long)view.tag);
    [_videoRecorder stopRecording];
    [self hideRecordingIndicator];
}

- (void)LPTHCancelLongPressWithTargetView:(UIView *)view{
    DebugLog(@"TBMHomeViewController: LPTH:  cancelLongPress %ld", (long)view.tag);
    [_videoRecorder cancelRecording];
    [self hideRecordingIndicator];
}

- (void)showRecordingIndicator
{
    _centerLabel.hidden = NO;
}

- (void)hideRecordingIndicator
{
    _centerLabel.hidden = YES;
}


@end
