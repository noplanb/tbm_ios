//
//  TBMViewUtils.h
//  tbm
//
//  Created by Sani Elfishawy on 4/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBMViewUtils : NSObject
+ (BOOL)isChildViewASubview:(UIView *)childView ofParentView:(UIView *)parentView;
+ (NSMutableArray *)recursiveSubviewsOfView:(UIView *)view;
@end
