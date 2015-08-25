//
//  ZZAuthInteractor.h
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthInteractorIO.h"

@interface ZZAuthInteractor : NSObject <ZZAuthInteractorInput>

@property (nonatomic, weak) id<ZZAuthInteractorOutput> output;

@end

