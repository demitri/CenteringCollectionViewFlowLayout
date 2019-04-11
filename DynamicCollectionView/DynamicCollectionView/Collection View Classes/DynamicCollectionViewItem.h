//
//  DynamicCollectionViewItem.h
//  DynamicCollectionView
//
//  Created by Demitri Muna on 4/9/19.
//

#import <Cocoa/Cocoa.h>
#import "ColorView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DynamicCollectionViewItem : NSCollectionViewItem

@property (nonatomic, strong) IBOutlet ColorView *largeView;
@property (nonatomic, strong) IBOutlet ColorView *miniView;

@property (nonatomic, weak) IBOutlet NSTextField *largeViewTextField;
@property (nonatomic, weak) IBOutlet NSTextField *miniViewTextField;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *largeWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *miniWidthConstraint;

@end

NS_ASSUME_NONNULL_END
