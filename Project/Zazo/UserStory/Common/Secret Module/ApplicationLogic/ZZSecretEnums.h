//
//  ZZSecretEnums.h
//  Zazo
//
//  Created by ANODA on 8/29/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZSecretButtonCellType)
{
    ZZSecretButtonCellTypeNone = 0,
    ZZSecretButtonCellTypeDispatchButton,
    ZZSecretButtonCellTypeClearData,
    ZZSecretButtonCellTypeResetTutorial,
    ZZSecretButtonCellTypeFeatureOptions
};

typedef NS_ENUM(NSInteger, ZZSecretSwitchCellType)
{
    ZZSecretSwitchCellTypeDebug,
    ZZSecretSwitchCellTypeUseRearCamera,
    ZZSecretSwitchCellTypeSendBrokenVideo,
    ZZSecretSwitchCellTypeForceRegSMS,
    ZZSecretSwitchCellTypeForceRegCall,
    ZZSecretSwitchCellTypeEnableAllFeatures
};

@interface ZZSecretEnums : NSObject

@end
