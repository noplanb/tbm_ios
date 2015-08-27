//
//  ZZMenuInteractor.h
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuInteractorIO.h"

@interface ZZMenuInteractor : NSObject <ZZMenuInteractorInput>

@property (nonatomic, weak) id<ZZMenuInteractorOutput> output;

@end

