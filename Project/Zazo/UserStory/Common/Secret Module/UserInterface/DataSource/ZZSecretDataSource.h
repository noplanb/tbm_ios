//
//  ZZSecretDataSource.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ANMemoryStorage;

typedef NS_ENUM(NSInteger, ZZSection)
{
    ZZSectionOne,
    ZZSectionTwo
};

@protocol ZZSecretDataSourceDelegate <NSObject>

@end

@interface ZZSecretDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;
@property (nonatomic, weak) id<ZZSecretDataSourceDelegate> delegate;

- (void)setupStorageWithModels:(NSArray*)list;

@end
