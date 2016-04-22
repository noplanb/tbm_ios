//
//  ZZActionHandlerUserInterfaceDelegate.h
//  Zazo
//
//  Created by ANODA on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridPart.h"

@protocol ZZGridActionHanlderUserInterfaceDelegate <NSObject>

- (CGRect)focusFrameForIndex:(NSInteger)index;

@end