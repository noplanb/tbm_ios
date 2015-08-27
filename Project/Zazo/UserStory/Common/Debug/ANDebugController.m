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
#import "ZZSecretScreenWireframe.h"

typedef NS_ENUM(NSInteger, ANSections)
{
    ZZAuthController,
    ZZGridController,
    ZZSecretController,
    ZZStateController,
    ZZMenuController
};

@implementation ANDebugController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        tableView.rowHeight = 55;
        [self registerCellClass:[ANBaseListTableCell class] forModelClass:[NSString class]];
        [self _setupStorage];
    }
    return self;
}

- (void)_setupStorage
{
    [self.memoryStorage addItems:@[
                                   @"Auth Module",
                                   @"Grid Module",
                                   @"Secret Module",
                                   @"State Module",
                                   @"Menu Module"
                                   ]];
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
           
        case ZZSecretController:
        {
            ZZSecretScreenWireframe* wireframe = [ZZSecretScreenWireframe new];
            [wireframe presentSecretScreenControllerFromNavigationController:self.rootController.navigationController];
        } break;
            
        default: break;
    }
}

@end
