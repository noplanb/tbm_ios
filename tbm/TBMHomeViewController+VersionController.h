//
//  TBMHomeViewController+VersionController.h
//  tbm
//
//  Created by Sani Elfishawy on 8/20/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"

@interface TBMHomeViewController (VersionController) <TBMVersionHandlerDelegate, UIAlertViewDelegate>

- (void)versionCheckCallback:(NSString *)response;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
