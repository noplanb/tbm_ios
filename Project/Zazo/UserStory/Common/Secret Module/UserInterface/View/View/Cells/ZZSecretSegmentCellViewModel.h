//
//  ZZSecretSwitchServerCellViewModel.h
//  Zazo
//
//  Created by ANODA on 8/29/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@class ZZSecretSegmentCellViewModel;

@protocol ZZSecretSegmentCellViewModelDelegate <NSObject>

- (void)viewModel:(ZZSecretSegmentCellViewModel*)model updatedSegmentValueTo:(NSInteger)value;

@end

@interface ZZSecretSegmentCellViewModel : NSObject

@property (nonatomic, weak) id<ZZSecretSegmentCellViewModelDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedIndex;

+ (instancetype)viewModelWithTitles:(NSArray*)titles;

- (NSArray*)titles;
- (void)updateSelectedValueTo:(NSInteger)value;

@end
