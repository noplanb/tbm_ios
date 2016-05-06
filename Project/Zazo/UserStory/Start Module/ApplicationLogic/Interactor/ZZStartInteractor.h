//
//  ZZStartInteractor.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartInteractorIO.h"

@interface ZZStartInteractor : NSObject <ZZStartInteractorInput>

@property (nonatomic, weak) id <ZZStartInteractorOutput> output;

@end

