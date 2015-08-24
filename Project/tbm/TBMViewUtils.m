//
//  TBMViewUtils.m
//  tbm
//
//  Created by Sani Elfishawy on 4/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMViewUtils.h"

@implementation TBMViewUtils

+ (BOOL)isChildViewASubview:(UIView *)childView ofParentView:(UIView *)parentView
{
    NSMutableArray *subviews = [self recursiveSubviewsOfView:parentView];
    return [subviews containsObject:childView];
}

+ (NSMutableArray *)recursiveSubviewsOfView:(UIView *)view
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSMutableArray *viewsToProcess = [[NSMutableArray alloc] init];
    [viewsToProcess addObject:view];
    
    while ([viewsToProcess count] != 0) {
        UIView *viewBeingProcessed = [viewsToProcess lastObject];
        [viewsToProcess removeLastObject];
        for (UIView *view in viewBeingProcessed.subviews){
            if ([view.subviews count] > 0){
                [viewsToProcess addObject:view];
            }
            [result addObject:view];
        }
    }
    return result;
}


@end
