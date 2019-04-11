//
//  CenteredFlowLayout.h
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
// This layout takes into account the minimum sectionInset.
//
// The basic algorithm is to take the view's width, subtract the total width of
// all items in a row, and divide the remaining white space evenly between the
// items and the edges, as long as the sectionInset minimum widths are honored.
// The number of rows/columns determined by NSCollectionViewFlowLayout should
// not change, only the spacing. The section inset values are thus reinterpreted
// as minimum section inset widths.
//
// Note: The containing view cannot go less than the minimum width of the items
//       plus a small padding (10pt seems to work), otherwise the view will
//       break with this error:
//
//       The behavior of the UICollectionViewFlowLayout is not defined because:
//       the item width must be less than the width of the UICollectionView minus
//       the section insets left and right values, minus the content insets left and right values.
//
//       To avoid this error I place a >= width constraint on the NSScrollView
//       enclosing the NSCollectionView. For example, if the minimum width is 100
//       and the left and right insets are 5, set the minimum width constraint to 100+5+5+10 = 120.

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CenteredFlowLayout : NSCollectionViewFlowLayout

@end

NS_ASSUME_NONNULL_END
