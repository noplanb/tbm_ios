//
// Created by Maksim Bazarov on 28.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBMStateScreenDataSource : NSObject


@property(nonatomic, strong) NSArray *friendsFiles;
@property(nonatomic, strong) NSArray *incomingFiles;
@property(nonatomic, strong) NSArray *outgoingFiles;

- (void)loadFriendsVideos;

- (void)loadVideos;

- (void)excludeNonDanglingFiles;

@end