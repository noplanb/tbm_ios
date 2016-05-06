//
//  ZZSecrectValueCellViewModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/31/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface ZZSecretValueCellViewModel : NSObject

+ (instancetype)viewModelWithTitle:(NSString *)title details:(NSString *)details;

- (NSString *)title;

- (NSString *)details;

@end
