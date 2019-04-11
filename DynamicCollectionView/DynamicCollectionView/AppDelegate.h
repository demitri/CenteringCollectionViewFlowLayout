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
@property (nonatomic, strong) IBOutlet NSCollectionViewFlowLayout *customLayout;

- (IBAction)defaultLayoutAction:(id)sender;

@end

