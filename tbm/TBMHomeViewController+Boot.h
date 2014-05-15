//
//  TBMHomeViewController+Boot.h
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"
#import "TBMRegisterProtocol.h"

@interface TBMHomeViewController (Boot) <TBMRegisterProtocol, UIAlertViewDelegate>
- (void)boot;
@end
