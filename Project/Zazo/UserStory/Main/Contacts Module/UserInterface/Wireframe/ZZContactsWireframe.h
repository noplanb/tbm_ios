//
//  ZZContactsWireframe.h
//  Versoos
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsModuleDelegate.h"

@class ZZMainWireframe, ZZContactsPresenter;

@interface ZZContactsWireframe : NSObject

@property (nonatomic, strong, readonly) UIViewController*contactsController;
@property (nonatomic, strong, readonly) ZZContactsPresenter * presenter;
@property (nonatomic, strong) ZZMainWireframe* mainWireframe;

@end
