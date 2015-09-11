//
//  ZZVideoNetworkTransportService.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZVideoNetworkTransportService : NSObject

+ (RACSignal*)deleteVideoFileWithName:(NSString*)filename;

@end
