//
//  ANBaseTableFooterView.m
//
//  Created by Oksana Kovalchuk on 5/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANBaseTableFooterView.h"
#import "UIFont+ANAdditions.h"
#import "UIColor+ANAdditions.h"

@implementation ANBaseTableFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.textLabel.font = [UIFont an_regularFontWithSize:13];
        self.textLabel.textColor = [UIColor an_colorWithHexString:@"777777"];
        self.textLabel.numberOfLines = 0;
    }
    return self;
}

- (void)updateWithModel:(NSString *)model
{
    self.textLabel.text = NSLocalizedString(model, nil);
}

@end
