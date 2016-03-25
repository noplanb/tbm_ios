//
//  ZZContactsInteractor.h
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsInteractorIO.h"

@interface ZZContactsInteractor : NSObject <ZZContactsInteractorInput>

@property (nonatomic, weak) id<ZZContactsInteractorOutput> output;

@end

