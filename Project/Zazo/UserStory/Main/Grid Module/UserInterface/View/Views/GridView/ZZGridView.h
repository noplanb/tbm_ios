//
//  ZZGridView.h
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZZGridView : UIView

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIImageView* titleImageView;
@property (nonatomic, strong) UIButton* menuButton;

@end
