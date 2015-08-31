//
//  ZZGridCollectionLayout.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionLayout.h"

#define IS_IPHONE_4             ([[UIScreen mainScreen] bounds].size.height == 480.0f)

enum WheelAlignmentType : NSInteger {
    WHEELALIGNMENTLEFT,
    WHEELALIGNMENTCENTER
};

const NSInteger kMaxCellSpacing = 9;

@interface UICollectionViewLayout ()

@property (nonatomic, assign) NSInteger cellCount;
//@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat itemHeight;

@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat dialRadius;
@property (nonatomic, assign) CGFloat angularSpacing;
@property (nonatomic, assign) NSInteger wheelType;

@end

@implementation ZZGridCollectionLayout

- (instancetype)init
{
    if (self = [super init])
    {
        [self _setup];
    }
    return self;
}

- (void)_setup
{
     self.sectionInset = UIEdgeInsetsMake(12,12,12,12);
    
    if (IS_IPHONE_4)
    {
        self.itemSize = CGSizeMake(96, 128);
        self.minimumInteritemSpacing = 4;
        self.minimumLineSpacing = 4;
    }
    else if (IS_IPHONE_5)
    {
        self.itemSize = CGSizeMake(96, 137.5);
        self.minimumInteritemSpacing = 4;
        self.minimumLineSpacing = 4;
    }
    else if (IS_IPHONE_6 )
    {
        self.itemSize = CGSizeMake(114, 163);
        self.minimumInteritemSpacing = 4.5;
        self.minimumLineSpacing = 4.5;
    }
    else if (IS_IPHONE_6_PLUS)
    {
        self.itemSize = CGSizeMake(127,182);
        self.minimumInteritemSpacing = 4.5;
        self.minimumLineSpacing = 4.5;
    }
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* attributes = [super layoutAttributesForElementsInRect:rect];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *theAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    return theAttributes;
}

@end
