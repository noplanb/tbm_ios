//
//  ZZSecretScreenView.h
//  Zazo
//
//  Created by ANODA on 21/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenLabelsInfoView.h"
#import "ZZSecretScreenButtonView.h"


typedef NS_ENUM(NSInteger, ZZServerType)
{
    ZZServerProdType,
    ZZServerStageType,
    ZZServerCustomType
};

@interface ZZSecretScreenView : UIView

@property (nonatomic, strong) UISegmentedControl* serverTypeControl;
@property (nonatomic, strong) ZZSecretScreenLabelsInfoView* labelsInfoView;
@property (nonatomic, strong) UISwitch* debugModeSwitch;
@property (nonatomic, strong) ZZSecretScreenButtonView* buttonView;

@end
