//
//  ZZMenuModuleInterface.h
//  zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZMenuModuleInterface <NSObject>

- (void)itemSelected:(id)item;
- (void)menuToggled;

@end
