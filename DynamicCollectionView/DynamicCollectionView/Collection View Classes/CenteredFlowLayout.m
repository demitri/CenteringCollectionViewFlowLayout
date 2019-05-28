//
//  CenteredFlowLayout.m
//
//  Created by Demitri Muna on 4/10/19.
//

#import "CenteredFlowLayout.h"
#import <math.h>

/*
@interface CenteredFlowLayout()
{
    CGFloat itemWidth;   // wdith of item; assuming all items have the same width
    NSUInteger nColumns; // number of possible columns based on item width and section insets
    CGFloat gridSpacing; // after even distribution, space between each item and edges (if row full)
    NSUInteger itemCount;
}
- (NSUInteger)columnForIndexPath:(NSIndexPath*)indexPath;
@end
*/

#pragma mark -

@implementation CenteredFlowLayout

{
    //CGFloat itemWidth;  // wdith of item; assuming all items have the same width
	NSSize itemSize;	  // size of the collection view item; assuming all items have the same size
    NSUInteger nColumns;  // number of possible columns based on item width and section insets
    CGFloat gridSpacing;  // after even distribution, space between each item and edges (if row full)
    NSUInteger itemCount;
	NSEdgeInsets insets;  // section insets might be from delegate method or property (see below)
	
	NSMutableDictionary<NSIndexPath*, NSCollectionViewLayoutAttributes*>  *preAnimationBounds;
}

- (void)prepareLayout
{
    [super prepareLayout];

    __auto_type delegate = (id<NSCollectionViewDelegateFlowLayout,NSCollectionViewDataSource>)self.collectionView.delegate;
    __auto_type cv = self.collectionView;

    /* same as:
    id<NSCollectionViewDelegateFlowLayout,NSCollectionViewDataSource> delegate = (id<NSCollectionViewDelegateFlowLayout,NSCollectionViewDataSource>)self.collectionView.delegate;
    NSCollectionView *cv = self.collectionView;
     */
    
    if ([delegate collectionView:cv numberOfItemsInSection:0] == 0)
        return;
    
    itemCount = [delegate collectionView:cv numberOfItemsInSection:0];
    
    // Determine the maximum number of items per row (i.e. number of columns)
    //
    // Get width of first item (assuming all are the same)
    // Get the attributes returned by NSCollectionViewFlowLayout, not our method override.
    NSUInteger indices[] = {0,0};
    NSCollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathWithIndexes:indices length:2]];
	itemSize = attr.size;
    
    //NSEdgeInsets insets;
    if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)])
        insets = [delegate collectionView:cv layout:self insetForSectionAtIndex:0];
    else
        insets = self.sectionInset;

    // calculate the number of columns that can fit excluding minimumInteritemSpacing:
    nColumns = floor((cv.frame.size.width - insets.left - insets.right) / itemSize.width);
    // is there enough space for minimumInteritemSpacing?
    while ((cv.frame.size.width
            - insets.left - insets.right
            - (nColumns*itemSize.width)
            - (nColumns-1)*self.minimumInteritemSpacing) < 0) {
        if (nColumns == 1)
            break;
        else
            nColumns--;
    }
    
    if (nColumns > itemCount)
        nColumns = itemCount; // account for a very wide window and few items
    
    // Calculate grid spacing
    // For a centered layout, all spacing (left inset, right inset, space between items) is equal
    // unless a row has fewer items than columns (but they are still aligned with that grid).
    //
    CGFloat totalWhitespace = cv.bounds.size.width - (nColumns * itemSize.width);
    gridSpacing = floor(totalWhitespace/(nColumns+1));  // e.g.:   |  [x]  [x]  |
    //gridSpacing = MAX(gridSpacing, MAX(self.sectionInset.left,self.sectionInset.right));
    
    //NSLog(@"gridSpacing = %d", (int)gridSpacing);
}

- (void)prepareForAnimatedBoundsChange:(NSRect)oldBounds
{
	// From the docs:
	// The collection view calls this method before performing any animated changes to the collection view’s bounds. It also calls this method before the animated insertion or deletion of items. Subclasses can use this method to perform any calculations needed to prepare fodr animated changes. Specifically, you might use this method to calculate the initial or final positions of inserted or deleted items so that you can return those values when asked for them.
	
	// I CAN'T SEE ANY SITUATION IN THIS APP WHERE THIS IS CALLED, EVEN WHEN CHANGING ITEM COUNTS
	
	for (NSCollectionViewLayoutAttributes* attributes in [self layoutAttributesForElementsInRect:oldBounds]) {
		preAnimationBounds[[attributes.indexPath copy]] = [attributes copy];
	}
}

- (void)prepareForCollectionViewUpdates:(NSArray<NSCollectionViewUpdateItem *> *)updateItems
{
	// I CAN'T SEE ANY SITUATION IN THIS APP WHERE THIS IS CALLED, EVEN WHEN CHANGING ITEM COUNTS

	[super prepareForCollectionViewUpdates:updateItems];
	
	for (NSCollectionViewUpdateItem *item in updateItems) {
		NSLog(@"updated item: %@", item);
	}
}

- (NSUInteger)columnForIndexPath:(NSIndexPath*)indexPath
{
    // given an index path in a collection view, return which column in the grid the item appears
    NSUInteger index = [indexPath indexAtPosition:1];
    NSUInteger row = (NSUInteger)floor(index/nColumns);
    return (index - (nColumns * row));
}

- (NSArray<__kindof NSCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(NSRect)rect
{
    // We do not need to modify the number of rows/columns that NSCollectionViewFlowLayout
    // determines, we just need to adjust the x position to keep them evenly distributed horizontally.

    if (nColumns == 0) // prepareLayout not yet called
        return [super layoutAttributesForElementsInRect:rect];
    
    // if there's only one item, it actually looks more weird to have it flow centered in all that space
    if ([self.collectionView numberOfItemsInSection:0] == 1)
        return [super layoutAttributesForElementsInRect:rect];

    NSArray *defaultAttributes = [super layoutAttributesForElementsInRect:rect];
    if (defaultAttributes.count == 0)
        return defaultAttributes;
	
	// If modifying, must return copies of attribute objects, not the originals modified
	NSMutableArray *newAttributes = [NSMutableArray array];
	
	CGFloat interitemSpacing = self.minimumInteritemSpacing;

	// Note: becuase of the use of floor() in the calcualtion of the gridSpacing (above), there can
	// be a discrepancy when the width of the view is within a few pixels of the width between a
	// different number of rows. In principle there shouldn't be a difference between the
	// default layout and this layout expcet for the frame origin x values, but in practice there were edge
	// cases that broke. For this reason, the frame origin y values are also calculated below.
	// This seems to have addressed the problem.
	
    for (NSCollectionViewLayoutAttributes *defaultAttribute in defaultAttributes) {
		NSCollectionViewLayoutAttributes *newAttr = [defaultAttribute copy];
        NSUInteger col = [self columnForIndexPath:newAttr.indexPath]; // column number
		NSUInteger row = (NSUInteger)floor([newAttr.indexPath indexAtPosition:1]/nColumns); // expected row number
        NSRect newFrame = NSMakeRect(floor((col * itemSize.width) + gridSpacing * (1 + col)),
                                     insets.top + (itemSize.height * row) + (interitemSpacing * row), //attr.frame.origin.y,
                                     newAttr.frame.size.width,
                                     newAttr.frame.size.height);
        newAttr.frame = newFrame;
		[newAttributes addObject:newAttr];
    }
    return newAttributes;
}

- (NSCollectionViewLayoutAttributes*)layoutAttributesForInterItemGapBeforeIndexPath:(NSIndexPath *)indexPath
{
    // Thought to try to just modify this, but this method not normally called
    // (maybe for drag/drop?).
    NSCollectionViewLayoutAttributes *attributes = [super layoutAttributesForInterItemGapBeforeIndexPath:indexPath];
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(NSRect)newBounds
{
	return YES;
}

@end
