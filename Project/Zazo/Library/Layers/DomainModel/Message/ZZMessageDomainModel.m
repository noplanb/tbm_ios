//
//  ZZMessageDomainModel.m
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZMessageDomainModel.h"

@implementation ZZMessageDomainModel

- (void)setMessageTypeAsString:(NSString *)string
{
    if ([string isEqualToString:@"text"]) {
        self.type = ZZMessageTypeText;
        return;
    }
    
    if ([string isEqualToString:@"transcript"]) {
        self.type = ZZMessageTypeTranscript;
        return;
    }
    
    self.type = ZZMessageTypeUnknown;
}

@end
