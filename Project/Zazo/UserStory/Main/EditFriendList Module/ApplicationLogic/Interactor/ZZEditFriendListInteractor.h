//
//  ZZEditFriendListInteractor.h
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListInteractorIO.h"

@interface ZZEditFriendListInteractor : NSObject <ZZEditFriendListInteractorInput>

@property (nonatomic, weak) id<ZZEditFriendListInteractorOutput> output;

@end

