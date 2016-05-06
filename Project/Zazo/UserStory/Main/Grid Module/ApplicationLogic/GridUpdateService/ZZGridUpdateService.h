//
//  ZZGridUpdateService.h
//  Zazo
//
//  Created by ANODA on 11/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


@protocol ZZGridUpdateServiceDelegate <NSObject>

- (void)updateGridDataWithModels:(NSArray *)models;

@end

@interface ZZGridUpdateService : NSObject


@property (nonatomic, weak) id <ZZGridUpdateServiceDelegate> delegate;

- (void)updateFriendsIfNeeded;

@end
