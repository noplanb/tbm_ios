//
//  ZZGridVC.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridViewInterface.h"
#import "ZZGridModuleInterface.h"
#import "ZZBaseVC.h"

@protocol ZZGridVCDelegate;
@interface ZZGridVC : ZZBaseVC <ZZGridViewInterface>

@property (nonatomic, weak) id<ZZGridModuleInterface> eventHandler;
@property (nonatomic, weak) id<ZZGridVCDelegate> vcDelegate;


@end
