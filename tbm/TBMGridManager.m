//
//  TBMGridManager.m
//  tbm
//
//  Created by Sani Elfishawy on 11/5/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMGridManager.h"
#import "TBMGridElement.h"

static id<GridEventCallback> delegate;

@implementation TBMGridManager

+ (void)setGridEventNotificationDelegate:(id<GridEventCallback>)ged{
    delegate = ged;
}

+ (NSMutableArray *)friendsOnGrid{
    NSMutableArray *r = [[NSMutableArray alloc] init];
    for (TBMGridElement *ge in [TBMGridElement all]){
        if (ge.friend != nil){
            [r addObject:ge.friend];
        }
    }
    return r;
}

+ (NSMutableArray *)friendsOnBench{
    NSMutableArray *allFriends = [[NSMutableArray alloc] initWithArray:[TBMFriend all]];
    NSMutableArray *gridFriends = [TBMGridManager friendsOnGrid];
    for (TBMFriend *gf in gridFriends){
        [allFriends removeObject:gf];
    }
    return allFriends;
}

+ (void)moveFriendToGrid:(TBMFriend *)friend{
    [TBMGridManager rankingActionOccurred:friend];
    if ([TBMGridElement friendIsOnGrid:friend])
        return;
    
    [TBMGridManager nextAvailableGridElement].friend = friend;
    if (delegate != nil)
        [delegate gridDidChange];
    
    [TBMGridManager highlightElementWithFriend:friend];
}


//--------
// Ranking
//--------

+ (void)rankingActionOccurred:(TBMFriend *)friend{
    friend.timeOfLastAction = [NSDate date];
}

+ (NSArray *) rankedFriendsOnGrid{
    return [[TBMGridManager friendsOnGrid] sortedArrayUsingComparator:^NSComparisonResult(TBMFriend *a, TBMFriend *b) {
        return [a.timeOfLastAction compare: b.timeOfLastAction];
    }];
}

+ (TBMFriend *)lowestRankedFriendOnGrid{
    return [[TBMGridManager rankedFriendsOnGrid] objectAtIndex:0];
}

+ (TBMGridElement *)nextAvailableGridElement{
    TBMGridElement *ge = [TBMGridElement firstEmptyGridElement];
    
    if (ge != nil)
        return ge;
    
    return [TBMGridElement findWithFriend:[TBMGridManager lowestRankedFriendOnGrid]];
}



//---
// UI
//---
+ (void)update{
    for (TBMGridElement *ge in [TBMGridElement all]){
        [TBMGridManager updateLabelWithGridElementOnMainThread:ge];
    }
}

+ (void)updateLabelWithGridElementOnMainThread:(TBMGridElement *)gridElement{
    [self performSelectorOnMainThread:@selector(updateLabelWithGridElement:) withObject:gridElement waitUntilDone:YES];
}

+ (void)updateLabelWithGridElement:(TBMGridElement *)gridElement{
    TBMFriend *f = gridElement.friend;
    if (f==nil)
        return;
    
    gridElement.label.text = [f videoStatusString];
    [gridElement.label setNeedsDisplay];
}

+ (void)highlightElementWithFriend:(TBMFriend *)friend{
    TBMGridElement *ge = [TBMGridElement findWithFriend:friend];
    if (ge == nil)
        return;
    
    //TODO: Add animiation for highlighting
}

//---------------------
// External convenience
//---------------------
+ (TBMVideoPlayer *)videoPlayerWithFriend:(TBMFriend *)friend{
    TBMGridElement *ge = [TBMGridElement findWithFriend:friend];
    if (ge == nil)
        return nil;
    
    return ge.videoPlayer;
}

@end

