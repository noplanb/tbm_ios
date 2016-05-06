//
//  NSError+Extensions.h
//  Zazo
//
//  Created by Sani Elfishawy on 4/23/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface NSError (Extensions)

+ (NSError *)errorWithError:(NSError *)error reason:(NSString *)reason;

@end
