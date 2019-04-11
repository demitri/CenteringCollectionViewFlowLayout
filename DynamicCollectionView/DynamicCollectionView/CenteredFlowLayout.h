//
//  CenteredFlowLayout.h
//  DynamicCollectionView
//
//  Created by Demitri Muna on 4/10/19.
//

// This NSCollectionViewLayout behaves exactly like NSCollectionViewFlowLayout
// except that the views are distributed evenly in the available whitespace.
// e.g.:
//  | [x] [x] [x]     |
//  | [x] [x]         |  <- NSCollectionViewFlowLayout, assuming inset of [ ] here.

//  |  [x]  [x]  [x]  |
//  |  [x]  [x]       |  <- this layout, assuming inset of [ ] here.
//
// This is a more aesthetic spacing for collection view items with large widths.
// This laytout takes into account the minimum sectionInset.
//
// The basic algorithm is to take the view's width, subtract the total width of
// all items in a row, and divide the remaining white space evenly between the
// items and the edges, as long as the sectionInset minimum widths are honored.
// The number of rows/columns determined by NSCollectionViewFlowLayout should
// not change, only the spacing. The section inset values are thus reinterpreted
// as minimum section inset widths.

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CenteredFlowLayout : NSCollectionViewFlowLayout

@end

NS_ASSUME_NONNULL_END
