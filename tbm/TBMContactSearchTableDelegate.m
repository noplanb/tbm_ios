//
//  TBMContactSearchTableDelegate.m
//  tbm
//
//  Created by Sani Elfishawy on 11/20/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//


#import "TBMContactSearchTableDelegate.h"
#import "HexColor.h"

@interface TBMContactSearchTableDelegate()
@property (nonatomic) NSString *cellId;
@property (nonatomic, copy) void (^selectCallback)(NSString *);
@end

@implementation TBMContactSearchTableDelegate

- (instancetype)initWithSelectCallback:(void (^)(NSString *))selectCallback{
    self = [super init];
    if (self != nil){
        _dataArray = [[NSArray alloc] init];
        _cellId = @"contactSearchCellId";
        _cellBackgroundColor = @"555";
        _cellTextColor = @"fff";
        _selectCallback = selectCallback;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellId];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18.0];
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor colorWithHexString:self.cellBackgroundColor alpha:1];
    cell.textLabel.textColor = [UIColor colorWithHexString:self.cellTextColor alpha:1];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *item = [self.dataArray objectAtIndex:indexPath.row];
    _selectCallback(item);
}


@end
