//
//  ANTableViewHeaderFooterView.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableViewHeaderFooterView.h"

@implementation ANTableViewHeaderFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    
}

- (void)updateWithModel:(id)model
{
    NSString * reason = [NSString stringWithFormat:@"view %@ should implement %@: method\n",
                         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
    NSException * exc =
    [NSException exceptionWithName:@"ANTableViewController API exception"
                            reason:reason
                          userInfo:nil];
    [exc raise];
}

- (id)model
{
    return nil;
}

- (void)setIsTransparent:(BOOL)isTransparent
{
    if (isTransparent)
    {
        self.backgroundView = [UIView new];
    }
    _isTransparent = isTransparent;
}

@end
