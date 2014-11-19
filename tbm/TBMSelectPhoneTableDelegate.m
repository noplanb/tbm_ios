//
//  TBMSelectPhoneTableDelegate.m
//  tbm
//
//  Created by Sani Elfishawy on 11/14/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMSelectPhoneTableDelegate.h"
#import "TBMContactsManager.h"

@interface TBMSelectPhoneTableDelegate()
@property NSDictionary *contact;
@property id <TBMSelectPhoneTableCallback> delegate;
@end

static NSString *SelectPhoneCellReuseId = @"phoneCell";

@implementation TBMSelectPhoneTableDelegate

- initWithContact:(NSDictionary *)contact delegate:(id<TBMSelectPhoneTableCallback>)delegate{
    self = [super init];
    if (self != nil){
        _contact = contact;
        _delegate = delegate;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DebugLog(@"cellForRowAtIndexPath");
    
    NSDictionary *pinfo = [[self.contact objectForKey:kContactsManagerPhonesArrayKey] objectAtIndex:indexPath.row];
    NSString *pn = [pinfo objectForKey:kContactsManagerPhoneNumberKey];
    NSString *pt = [pinfo objectForKey:kContactsManagerPhoneTypeKey];
    
    UITableViewCell *pc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SelectPhoneCellReuseId];
    pc.textLabel.text = pn;
    pc.detailTextLabel.text = pt;
    
    DebugLog(@"cell height %f", pc.frame.size.height);
    return pc;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    DebugLog(@"numberOfRowsInSection");
    return [[self.contact objectForKey:kContactsManagerPhonesSetKey] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DebugLog(@"didSelectRowAtIndexPath");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *pinfo = [[self.contact objectForKey:kContactsManagerPhonesSetKey] objectAtIndex:indexPath.row];
    [[self delegate] didClickOnPhoneObject:pinfo];
}

@end
