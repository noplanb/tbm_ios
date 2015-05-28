//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMStateScreenViewController.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMStateScreenDataSource.h"
#import "TBMFriendVideos.h"
#import "TBMVideo.h"
#import "TBMFriend.h"

@interface TBMStateScreenViewController ()
@property(nonatomic) TBMSecretScreenPresenter *presenter;
@property(nonatomic, strong) UITextView *textView;
@end

@implementation TBMStateScreenViewController {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.textView];
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

#pragma mark - Helpers

void appendLog(NSMutableString *description, NSString *title, NSString *value) {
    [description appendString:title];
    if (value) {
        [description appendString:value];
    }
    [description appendString:@"\n"];
}

NSString *outgoing_status(TBMOutgoingVideoStatus status) {
    NSArray *statuses = @[
            @"OUTGOING_VIDEO_STATUS_NONE",
            @"OUTGOING_VIDEO_STATUS_NEW",
            @"OUTGOING_VIDEO_STATUS_QUEUED",
            @"OUTGOING_VIDEO_STATUS_UPLOADING",
            @"OUTGOING_VIDEO_STATUS_UPLOADED",
            @"OUTGOING_VIDEO_STATUS_DOWNLOADED",
            @"OUTGOING_VIDEO_STATUS_VIEWED",
            @"OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY]"
    ];

    return statuses[status];
}


NSString *incoming_status(TBMIncomingVideoStatus status) {
    NSArray *statuses = @[
            @"INCOMING_VIDEO_STATUS_NEW",
            @"INCOMING_VIDEO_STATUS_DOWNLOADING",
            @"INCOMING_VIDEO_STATUS_DOWNLOADED",
            @"INCOMING_VIDEO_STATUS_VIEWED",
            @"INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY"
    ];
    return statuses[status];
}

- (void)updateUserInterfaceWithData:(TBMStateScreenDataSource *)data {
    NSMutableString *stateLog = [@"" mutableCopy];

    appendLog(stateLog, @"******* FRIENDS FILES ******* ", @"");
    for (TBMFriendVideos *friendVideos in data.friendsFiles) {
        appendLog(stateLog, @"--------------", @"----------------");
        appendLog(stateLog, @"| FRIEND:", friendVideos.name);
        appendLog(stateLog, @"--------------", @"----------------");
        appendLog(stateLog, @"| INCOMING FILES", @"\n");
        for (TBMVideo *file in friendVideos.incomingVideos) {
            appendLog(stateLog, @"ID: ", file.videoId);
            appendLog(stateLog, @"STATUS: ", incoming_status(file.status));
            appendLog(stateLog, @"-", @"-");
        }
        appendLog(stateLog, @"| OUTGOING FILE", @"\n");
        appendLog(stateLog, @"| ID: ", friendVideos.outgoingVideoId);
        appendLog(stateLog, @"| STATUS: = ", outgoing_status(friendVideos.outgoingVideoStatus));
        appendLog(stateLog, @"----------------------------", @"----------------");
    }
    appendLog(stateLog, @"******* DANGLING INCOMING FILES ******* ", @"");

    for (NSString *file in data.incomingFiles) {
        appendLog(stateLog, @"- ", file);
        appendLog(stateLog, @"", @"\n");
    }

    appendLog(stateLog, @"******* DANGLING OUTGOING FILES ******* ", @"");
    for (NSString *file in data.outgoingFiles) {
        appendLog(stateLog, @"- ", file);
        appendLog(stateLog, @"", @"\n");
    }

    self.textView.text = stateLog;
}
@end