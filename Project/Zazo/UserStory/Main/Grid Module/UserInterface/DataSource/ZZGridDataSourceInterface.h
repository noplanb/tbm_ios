//
//  ZZGridDataSourceInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/2/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZGridDomainModel;
@class ZZGridCellViewModel;

@protocol ZZGridDataSourceControllerDelegate <NSObject>

- (void)reload;

- (void)reloadItemAtIndex:(NSInteger)index;

- (void)reloadItem:(id)item;

@end

@protocol ZZGridDataSourceDelegate <NSObject>

- (void)showHint;

- (void)switchCamera;

- (BOOL)isNetworkEnabled;

@end
