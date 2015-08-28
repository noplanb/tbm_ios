//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMStateScreenViewController.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMStateDataSource.h"
#import "TBMStateScreenView.h"
#import "TBMFriendVideosInformation.h"
#import "TBMVideoObject.h"

@interface TBMStateScreenViewController ()

@property(nonatomic) TBMSecretScreenPresenter *presenter;

@property(nonatomic, strong) TBMStateScreenView *stateScreenview;
@end

@implementation TBMStateScreenViewController {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stateScreenview = [[TBMStateScreenView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.stateScreenview];
        [self setupNavigationBar];
    }
    return self;
}

- (void)setupNavigationBar {
    self.title = @"State screen";
}

- (instancetype)initWithPresenter:(TBMSecretScreenPresenter *)presenter {
    self = [self init];
    if (self) {
        self.presenter = presenter;
    }
    return self;
}


- (void)updateUserInterfaceWithData:(TBMStateDataSource *)data {
    if (!data) {
        return;
    }

    NSMutableDictionary *tableData = [NSMutableDictionary dictionary];
    NSMutableArray *orderKeys = [NSMutableArray array];
    if (data.incomingFiles && data.incomingFiles.count) {
        NSString *danglingIncomingKey = @"DANGLING INCOMING FILES";
        NSMutableArray *incomingFiles = [@[] mutableCopy];
        for (NSString *videoFile in data.incomingFiles) {
            TBMVideoObject *videoObject = [TBMVideoObject makeVideoObjectWithVideoID:videoFile status:@"."];
            [incomingFiles addObject:videoObject];
        }
        tableData[danglingIncomingKey] = incomingFiles;
        [orderKeys addObject:danglingIncomingKey];
    }

    if (data.outgoingFiles && data.outgoingFiles.count) {
        NSString *danglingOutgoingKey = @"DANGLING OUTGOING FILES";
        NSMutableArray *outgoingFiles = [@[] mutableCopy];
        for (NSString *videoFile in data.outgoingFiles) {
            TBMVideoObject *videoObject = [TBMVideoObject makeVideoObjectWithVideoID:videoFile status:@"."];
            [outgoingFiles addObject:videoObject];
        }
        tableData[danglingOutgoingKey] = outgoingFiles;
        [orderKeys addObject:danglingOutgoingKey];
    }

    if (data.friendsVideoObjects && data.friendsVideoObjects.count) {
        for (NSUInteger index = 0; index < data.friendsVideoObjects.count; ++index) {
            TBMFriendVideosInformation *videoObject = data.friendsVideoObjects[index];

            if (videoObject) {
                NSString *friendName = videoObject.name;
                if (friendName) {
                    if (videoObject.outgoingObjects && videoObject.outgoingObjects.count) {
                        NSString *outgoingKey = [friendName stringByAppendingFormat:@" - Outgoing object"];
                        tableData[outgoingKey] = videoObject.outgoingObjects;
                        [orderKeys addObject:outgoingKey];
                    }

                    if (videoObject.incomingObjects && videoObject.incomingObjects.count) {
                        NSString *incomingKey = [friendName stringByAppendingFormat:@" - Incoming objects"];
                        tableData[incomingKey] = videoObject.incomingObjects;
                        [orderKeys addObject:incomingKey];
                    }

                }
            }

        }
    }

    [self.stateScreenview updateTableWithData:tableData orederKeys:orderKeys];
}

#pragma mark - Lazy initialization

@end