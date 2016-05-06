//
//  ZZDebugStateController.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateController.h"
#import "ZZDebugStateDataSource.h"

@import MobileCoreServices;

@implementation ZZDebugStateController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (self)
    {
        [self registerCellClass:[ZZDebugStateCell class] forModelClass:[ZZDebugStateCellViewModel class]];
        [self registerCellClass:[ZZDebugStateCell class] forModelClass:[NSString class]];

        self.displayHeaderOnEmptySection = NO;
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id model = [self.storage objectAtIndexPath:indexPath];
    NSString *details;
    if ([model isKindOfClass:[NSString class]])
    {
        details = model;
    }
    else
    {
        ZZDebugStateCellViewModel *viewModel = (ZZDebugStateCellViewModel *)model;
        details = [NSString stringWithFormat:@"%@ - %@", [viewModel title], [viewModel status]];
    }

    NSDictionary *text = @{(NSString *)kUTTypeUTF8PlainText : details};
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.items = @[text];
}

@end
