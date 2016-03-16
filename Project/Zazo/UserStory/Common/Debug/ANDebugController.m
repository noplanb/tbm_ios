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
#import "ZZMainWireframe.h"

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
    }
    return self;
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
            ZZMainWireframe*wireframe = [ZZMainWireframe new];
            [wireframe presentMainControllerFromWindow:self.rootController.view.window completion:nil];
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
