//
// Created by Rinat on 04/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZNumberBadge.h"
#import "ZZGridUIConstants.h"

@interface ZZNumberBadge ()

@property (nonatomic, weak, readonly) CATextLayer *textLayer;

@end

@implementation ZZNumberBadge {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        CATextLayer *textLayer = [CATextLayer layer];
        _textLayer = textLayer;
        [self.layer addSublayer:textLayer];

        textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = 18;
        textLayer.font = CFBridgingRetain([UIFont systemFontOfSize:18]);
        textLayer.contentsScale = [[UIScreen mainScreen] scale];
        textLayer.frame = CGRectMake(0, 1, kVideoCountLabelWidth, kVideoCountLabelWidth);

        self.hidden = YES;
        self.layer.delegate = self;
        self.count = NSUIntegerMax; // Skip initial count setting animation

    }

    return self;
}

- (void)setCount:(NSUInteger)count
{
    _count = count;

    {
        self.textLayer.string = [NSString stringWithFormat:@"%li", (long)count];
    }
}

@end