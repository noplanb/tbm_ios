//
//  TBMHomeViewControllerselfGrid.m
//  tbm
//
//  Created by Sani Elfishawy on 11/11/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController.h"
#import "TBMHomeViewController+Grid.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"
#import "OBLogger.h"
#import <objc/runtime.h>
#import "HexColor.h"


static NSInteger TBM_HOME_GRID_VIEW_INDEX_OFFSET = 10;
static NSInteger TBM_HOME_GRID_LABEL_INDEX_OFFSET = 20;

@implementation TBMHomeViewController (Grid)
//-----------------------------------------
// Instance variables as associated objects
//-----------------------------------------
// @property videoPlayers
- (void)setVideoPlayers:(id)newAssociatedObject {
    objc_setAssociatedObject(self, @selector(videoPlayers), newAssociatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray  *)videoPlayers {
    return (NSArray *)objc_getAssociatedObject(self, @selector(videoPlayers));
}


//---------------
// Initialization
//---------------
- (void)setupGrid{
    if ([TBMGridElement all].count != 8){
        [self createGridElements];
    }
    [self createVideoPlayers];
    [self updateAllGridViews];
}

- (void)createGridElements{
    [TBMGridElement destroyAll];
    
    NSArray *friends = [TBMFriend all];
    for (int i=0; i<8; i++){
        TBMGridElement *ge = [TBMGridElement create];
        if (i<friends.count)
            ge.friend = [friends objectAtIndex:i];
        ge.index = i;
    }
}

- (void)createVideoPlayers{
    NSMutableArray *vps =  [[NSMutableArray alloc] init];
    for (int i=0; i<8; i++){
        TBMGridElement *ge = [TBMGridElement findWithIndex:i];
        TBMVideoPlayer *vp = [[TBMVideoPlayer alloc] initWithGridElement:ge view:[self gridViewWithIndex:i]];
        [vps addObject:vp];
    }
    [self setVideoPlayers:vps];
}


//------------------------------------------
// Finders for labels views and videoPlayers
//------------------------------------------
- (UIView *)gridViewWithIndex:(int)i{
    int tag = i + TBM_HOME_GRID_VIEW_INDEX_OFFSET;
    for (UIView *view in self.gridViews) {
        if (view.tag == tag){
            return view;
        }
    }
    return nil;
}

- (UILabel *)gridLabelWithIndex:(int)i{
    int tag = i + TBM_HOME_GRID_LABEL_INDEX_OFFSET;
    for (UILabel *label in self.gridLabels){
        if (label.tag == tag){
            return label;
        }
    }
    return nil;
}

- (TBMVideoPlayer *)videoPlayerWithIndex:(int)i{
    return (TBMVideoPlayer *)[[self videoPlayers] objectAtIndex:i];
}

- (TBMVideoPlayer *)videoPlayerWithView:(UIView *)view{
    int index = view.tag - TBM_HOME_GRID_VIEW_INDEX_OFFSET;
    return [self videoPlayerWithIndex:index];
}

- (TBMGridElement *)gridElementWithView:(UIView *)view{
    int index = view.tag - TBM_HOME_GRID_VIEW_INDEX_OFFSET;
    return [TBMGridElement findWithIndex:index];
}

//-------------------------
// Handling friends on grid
//-------------------------
- (NSMutableArray *)friendsOnGrid{
    NSMutableArray *r = [[NSMutableArray alloc] init];
    for (TBMGridElement *ge in [TBMGridElement all]){
        if (ge.friend != nil){
            [r addObject:ge.friend];
        }
    }
    return r;
}

- (NSMutableArray *)friendsOnBench{
    NSMutableArray *allFriends = [[NSMutableArray alloc] initWithArray:[TBMFriend all]];
    NSMutableArray *gridFriends = [self friendsOnGrid];
    for (TBMFriend *gf in gridFriends){
        [allFriends removeObject:gf];
    }
    return allFriends;
}

- (void)moveFriendToGrid:(TBMFriend *)friend{
    OB_INFO(@"moveFriendToGrid: %@", friend.firstName);
    [self rankingActionOccurred:friend];
    if ([TBMGridElement friendIsOnGrid:friend]){
        [self highlightElement:[TBMGridElement findWithFriend:friend]];
        return;
    }
    
    TBMGridElement *ge = [self nextAvailableGridElement];
    OB_INFO(@"moveFriendToGrid: %@", ge);
    
    ge.friend = friend;
    OB_INFO(@"moveFriendToGrid after chaned friend: %@", ge.friend.firstName);
    
    [self updateElementViewOnMainThread:ge];
    [self highlightElement:ge];
}


//--------
// Ranking
//--------

- (void)rankingActionOccurred:(TBMFriend *)friend{
    friend.timeOfLastAction = [NSDate date];
}

- (NSArray *) rankedFriendsOnGrid{
    return [[self friendsOnGrid] sortedArrayUsingComparator:^NSComparisonResult(TBMFriend *a, TBMFriend *b) {
        return [a.timeOfLastAction compare: b.timeOfLastAction];
    }];
}

- (TBMFriend *)lowestRankedFriendOnGrid{
    return [[self rankedFriendsOnGrid] objectAtIndex:0];
}

- (TBMGridElement *)nextAvailableGridElement{
    TBMGridElement *ge = [TBMGridElement firstEmptyGridElement];
    
    if (ge != nil)
        return ge;
    
    return [TBMGridElement findWithFriend:[self lowestRankedFriendOnGrid]];
}



//---
// UI
//---
- (void)updateAllGridViews{
    for (TBMGridElement *ge in [TBMGridElement all]){
        [self updateElementViewOnMainThread:ge];
    }
}

- (void)updateElementViewOnMainThread:(TBMGridElement *)gridElement{
    [self performSelectorOnMainThread:@selector(updateLabelWithGridElement:) withObject:gridElement waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(updateVideoViewWithGridElement:) withObject:gridElement waitUntilDone:YES];
}

- (void) updateVideoViewWithGridElement:(TBMGridElement *)ge{
    [[[self videoPlayers] objectAtIndex:ge.index] updateView];
}

- (void)updateLabelWithGridElement:(TBMGridElement *)ge{
    TBMFriend *f = ge.friend;
    if (f==nil)
        return;
    
    UILabel *l = [self gridLabelWithIndex:ge.index];
    l.text = [f videoStatusString];
    [l setNeedsDisplay];
}

//---------------------------
// Highlighting a gridElement
//---------------------------
- (void)highlightElement:(TBMGridElement *)ge{
    UIView *gv = [self gridViewWithIndex:ge.index];
    CGRect r;
    r.size.width  = gv.frame.size.width;
    r.size.height = gv.frame.size.height;
    r.origin.x = 0;
    r.origin.y = 0;
    UIView *blaze = [[UIView alloc] initWithFrame:r];
    [blaze setBackgroundColor:[UIColor colorWithHexString:@"FBD330" alpha:1]];
    [blaze setAlpha:0];
    [gv addSubview:blaze];
    [gv setNeedsDisplay];
    [self performSelector:@selector(animateBlaze:) withObject:blaze afterDelay:0.3];
}

- (void)animateBlaze:(UIView *)blaze{
    [UIView animateWithDuration:0.3 animations:^{
        [blaze setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [blaze setAlpha:0];
        } completion:^(BOOL finished) {
            [blaze removeFromSuperview];
        }];
    }];
}

//---------------------
// External convenience
//---------------------
- (TBMVideoPlayer *)videoPlayerWithFriend:(TBMFriend *)friend{
    TBMGridElement *ge = [TBMGridElement findWithFriend:friend];
    if (ge == nil)
        return nil;
    
    return [[self videoPlayers] objectAtIndex:ge.index];
}


@end
