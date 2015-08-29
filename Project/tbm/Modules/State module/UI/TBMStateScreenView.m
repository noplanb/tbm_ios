//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMStateScreenView.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMVideoObject.h"
#import "TBMStateScreenTableCell.h"

@interface TBMStateScreenView ()

@property(nonatomic) TBMSecretScreenPresenter *presenter;
@property(nonatomic, strong) NSDictionary *data;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *sections;
@end

@implementation TBMStateScreenView

#pragma mark - Interface

- (void)updateTableWithData:(NSMutableDictionary *)data orederKeys:(NSMutableArray *)orderKeys {
    self.data = data;
    self.sections = orderKeys;
    [self.tableView reloadData];
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];

    [self.tableView registerClass:[TBMStateScreenTableCell class] forCellReuseIdentifier:@"TBMStateScreenTableCell"];
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark -  UITableViewDataSource

/*** SECTIONS ***/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections ? self.sections.count : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section < self.sections.count ? self.sections[section] : @"-";
}

/*** ROWS ***/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.sections[section];
    NSArray *rows = self.data[key];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"TBMStateScreenTableCell";
    TBMStateScreenTableCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        cell = [[TBMStateScreenTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    NSString *key = self.sections[indexPath.section];
    NSArray *rows = self.data[key];
    TBMVideoObject *videoObject = rows[indexPath.row];
    cell.mainText = videoObject.videoID;
    cell.additionalText = videoObject.videoStatus;

    return cell;
}


@end