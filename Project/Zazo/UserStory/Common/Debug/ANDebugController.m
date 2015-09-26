//
//  ANDebugController.m
//  Zazo
//
//  Created by ANODA on 2/18/15.
//  Copyright (c) 2015 Oksana Kovalchuk. All rights reserved.
//

#import "ANDebugController.h"
#import "ANBaseListTableCell.h"
#import "ZZAuthWireframe.h"
#import "ZZGridWireframe.h"
#import "ZZMenuWireframe.h"
#import "ZZEditFriendListWireframe.h"
#import "ZZSecretWireframe.h"
#import "ZZDebugStateWireframe.h"
#import "AVAudioSession+TBMAudioSession.h"

typedef NS_ENUM(NSInteger, ANSections)
{
    ZZAuthController,
    ZZGridController,
    ZZStateController,
    ZZMenuController,
    ZZEditFriendsController,
    ZZSecretController
};

@implementation ANDebugController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        tableView.rowHeight = 44;
        [self registerCellClass:[ANBaseListTableCell class] forModelClass:[NSString class]];
        [self _setupStorage];
        [self ensureAudioSession];
    }
    return self;
}


- (void)ensureAudioSession {
    OB_INFO(@"ensureAudioSession");
    [[AVAudioSession sharedInstance] setupApplicationAudioSession];
    if ([[AVAudioSession sharedInstance] activate] != nil){
        OB_INFO(@"Boot: No Audio Session");
//        [self alertEndProbablePhoneCall];
    } else {
        OB_INFO(@"Boot: Audio Session Granted");
        /**
         * Note that we call onResources available BEFORE we ensurePushNotification because on IOS7
         * we do not get any callback if user declines notifications.
         */
//        [self onResourcesAvailable];
//        [self ensurePushNotification];
    }
}


- (void)_setupStorage
{
    [self.memoryStorage addItems:@[@"Auth Module",
                                   @"Grid Module",
                                   @"State Module",
                                   @"Menu Module",
                                   @"Edit Friends Module",
                                   @"Secret Module"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row)
    {
        case ZZAuthController:
        {
            ZZAuthWireframe* wireframe = [ZZAuthWireframe new];
            [wireframe presentAuthControllerFromNavigationController:self.rootController.navigationController];
        } break;
            
        case ZZGridController:
        {
            ZZMenuWireframe* menuwireframe = [ZZMenuWireframe new];
            [menuwireframe presentMenuControllerFromWindow:self.rootController.view.window];
        } break;
            
        case ZZStateController:
        {
            ZZDebugStateWireframe* wireframe = [ZZDebugStateWireframe new];
            [wireframe presentDebugStateControllerFromNavigationController:self.rootController.navigationController];
        } break;
            
        case ZZMenuController:
        {
            
        } break;
            
        case ZZEditFriendsController:
        {
            ZZEditFriendListWireframe* wireframe = [ZZEditFriendListWireframe new];
            [wireframe presentEditFriendListControllerFromNavigationController:self.rootController.navigationController];
        } break;
            
        case ZZSecretController:
        {
            ZZSecretWireframe* wireframe = [ZZSecretWireframe new];
            [wireframe presentSecretControllerFromNavigationController:self.rootController.navigationController];
        } break;
            
        default: break;
    }
}

@end
