//
//  TBMLongPressTouchHandlerCallback.h
//  tbm
//
//  Created by Sani Elfishawy on 4/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMLongPressTouchHandlerCallback <NSObject>
- (void)LPTHClickWithTargetView:(UIView *)view;
- (void)LPTHStartLongPressWithTargetView:(UIView *)view;
- (void)LPTHEndLongPressWithTargetView:(UIView *)view;
- (void)LPTHCancelLongPressWithTargetView:(UIView *)view;
@end
