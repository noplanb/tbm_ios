//
//  ZZNetworkTestInteractor.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestInteractorIO.h"

@interface ZZNetworkTestInteractor : NSObject <ZZNetworkTestInteractorInput>

@property (nonatomic, weak) id <ZZNetworkTestInteractorOutput> output;

@end

