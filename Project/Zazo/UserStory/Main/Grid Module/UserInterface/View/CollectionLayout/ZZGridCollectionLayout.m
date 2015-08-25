//
//  ZZGridCollectionLayout.m
//  Zazo
//
//  Created by ANODA.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionLayout.h"

const NSInteger kMaxCellSpacing = 9;

@interface UICollectionViewLayout ()

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
    CGFloat headerViewHeight = 64;
    CGFloat interItemSpacing = 5;
    CGFloat sideInsets = 5;
    CGFloat lineSpacing = 5;
    CGFloat topSideInsets = (CGRectGetHeight([UIScreen mainScreen].bounds) - headerViewHeight)/12;
    CGFloat cellWidth = CGRectGetWidth([UIScreen mainScreen].bounds)/3 - interItemSpacing - sideInsets/2;
    CGFloat cellHeight = (CGRectGetHeight([UIScreen mainScreen].bounds) - headerViewHeight)/3 - topSideInsets;
    self.itemSize = CGSizeMake(cellWidth, cellHeight);
    self.sectionInset = UIEdgeInsetsMake(topSideInsets,sideInsets,topSideInsets,sideInsets);
    self.minimumInteritemSpacing = interItemSpacing;
    self.minimumLineSpacing = lineSpacing;
}

//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
//    for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
//        if (!attributes.representedElementKind)
//        {
//            NSIndexPath* indexPath = attributes.indexPath;
//            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
//        }
//    }
//    return attributesToReturn;
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewLayoutAttributes* currentInteAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
//    UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout sectionInset];
//    if (indexPath.item == 4)
//    {
////        CGRect frame = currentInteAttributes.frame;
////        frame.origin.x = 100;
////        
////        currentInteAttributes.frame = frame;
//        currentInteAttributes.alpha = 0;
//        return currentInteAttributes;
//    }
//    
//    
////    NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
////    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
////    CGFloat previousFrameRightPoint = previousFrame.origin.x
//    
//    return currentInteAttributes;
//
//}

@end
