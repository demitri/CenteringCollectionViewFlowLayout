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
    CGFloat itemWidth;   // wdith of item; assuming all items have the same width
    NSUInteger nColumns; // number of possible columns based on item width and section insets
    CGFloat gridSpacing; // after even distribution, space between each item and edges (if row full)
    NSUInteger itemCount;
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
    itemWidth = attr.size.width;
    
    NSEdgeInsets insets;
    if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)])
        insets = [delegate collectionView:cv layout:self insetForSectionAtIndex:0];
    else
        insets = self.sectionInset;

    // calculate the number of columns that can fit excluding minimumInteritemSpacing:
    nColumns = floor((cv.frame.size.width - insets.left - insets.right) / itemWidth);
    // is there enough space for minimumInteritemSpacing?
    while ((cv.frame.size.width
            - insets.left - insets.right
            - (nColumns*itemWidth)
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
    CGFloat totalWhitespace = cv.bounds.size.width - (nColumns * itemWidth);
    gridSpacing = floor(totalWhitespace/(nColumns+1));  // e.g.:   |  [x]  [x]  |
    //gridSpacing = MAX(gridSpacing, MAX(self.sectionInset.left,self.sectionInset.right));
    
    NSLog(@"gridSpacing = %d", (int)gridSpacing);
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
    
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    if (attributes.count == 0)
        return attributes;
	
	// If modifying, must return copies of attribute objects, not the originals modified
	NSMutableArray *newAttributes = [NSMutableArray array];
	
    //CGFloat inset = self.sectionInset.left;
    
    for (NSCollectionViewLayoutAttributes *attr in attributes) {
		NSCollectionViewLayoutAttributes *newAttr = [attr copy];
        NSUInteger col = [self columnForIndexPath:attr.indexPath]; // column number
        NSRect newFrame = NSMakeRect(floor((col * itemWidth) + gridSpacing * (1 + col)),
                                     attr.frame.origin.y,
                                     attr.frame.size.width,
                                     attr.frame.size.height);
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
    
    // Would have thought to only return YES when the width changes (in a flow layout),
    // but only returning "YES" works.
    //CGRect oldBounds = self.collectionView.bounds;
    //return CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds);
}

@end
