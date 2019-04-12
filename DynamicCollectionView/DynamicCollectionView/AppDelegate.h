//
//  AppDelegate.h
//  DynamicCollectionView
//
//  Created by Demitri Muna on 4/9/19.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSNumber *itemCount; // no. of items in collection; can be updated in window
@property (nonatomic, weak) IBOutlet NSCollectionView *collectionView;
@property (nonatomic, strong) IBOutlet NSCollectionViewFlowLayout *customLayout; // hang on to our custom layout when swapping with the default
@property (nonatomic, strong) IBOutlet NSButton *useSingleCollectionItemCheckbox;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewWidthConstraint; // could be used to programmatically set the minimum width constraint on the collection view; here, only coded in IB.

// IBActions
- (IBAction)defaultLayoutAction:(id)sender;
- (IBAction)swapItemClassAction:(id)sender;

@end

