//
//  AppDelegate.m
//  DynamicCollectionView
//
//  Created by Demitri Muna on 4/9/19.
//

#import "AppDelegate.h"

#define LARGE_THUMBNAIL_WIDTH 250 // hardcoded for now, but prefer not to be!

@interface AppDelegate ()
{
    BOOL displayMiniItems; // flag to indicate whether we should display mini collection view items
}
@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) id collectionViewFrameChangeObserver;
@end

#pragma mark -

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self addObserver:self
           forKeyPath:@"itemCount"
              options:NSKeyValueObservingOptionNew
              context:nil];

    // Note that "self.customLayout" is bound to the collection view's
    // layout. The pointer is to keep it around if we swap it out.
    
    self.itemCount = @4; // set initial collection size
    
    // determine initial size of items
    NSEdgeInsets insets = [(NSCollectionViewFlowLayout*) self.collectionView.collectionViewLayout sectionInset];
    displayMiniItems = (self.collectionView.frame.size.width < (LARGE_THUMBNAIL_WIDTH + insets.left + insets.right));
    
    // watch the frame size to switch to mini view when then width gets narrow
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    self.collectionView.postsFrameChangedNotifications = YES;
    self.collectionViewFrameChangeObserver = [nc addObserverForName:NSViewFrameDidChangeNotification
                                                             object:self.collectionView // .superview
                                                              queue:[NSOperationQueue mainQueue]
                                                         usingBlock:^(NSNotification * _Nonnull note) {
                                                             
                                                             // see if we are changing from mini to full size thumbnails
                                                             
                                                             NSLog(@"controller self.view w=%.1f", self.collectionView.frame.size.width);
                                                             
                                                             // enclosing view
                                                             BOOL currentFlag = self->displayMiniItems;

                                                             NSEdgeInsets insets = [(NSCollectionViewFlowLayout*) self.collectionView.collectionViewLayout sectionInset];
                                                             
                                                             // Values are hard coded, but prefer not to be.
                                                             // -> large item view width + left inset + right inset
                                                             self->displayMiniItems = (self.collectionView.frame.size.width < (LARGE_THUMBNAIL_WIDTH + insets.left + insets.right));
                                                             
                                                             if (currentFlag != self->displayMiniItems) {
                                                                 
                                                                 NSLog(@"\nflip w=%0.1f\n", self.collectionView.frame.size.width);
                                                                 
                                                                 [self.collectionView.collectionViewLayout invalidateLayout];
                                                                 [self.collectionView reloadData];
                                                             }
                                                         }];

    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {

    if (floor(NSAppKitVersionNumber) < NSAppKitVersionNumber10_11) {
        if (self.collectionViewFrameChangeObserver)
            [[NSNotificationCenter defaultCenter] removeObserver:self.collectionViewFrameChangeObserver];
    }

}

#pragma mark - IBAction methods

- (void)defaultLayoutAction:(id)sender
{
    //BOOL usingCustomLayout = [self.collectionView.collectionViewLayout isKindOfClass:NSCollectionViewFlowLayout.class];
    
    NSButton *checkboxButton = (NSButton*)sender;
    switch (checkboxButton.state) {
        case NSOnState:
        {
           // replace layout with NSCollectionViewFlowLayout.class
            NSCollectionViewFlowLayout *flowLayout = [[NSCollectionViewFlowLayout alloc] init];
            flowLayout.sectionInset = self.customLayout.sectionInset;
            flowLayout.minimumLineSpacing = self.customLayout.minimumLineSpacing;
            flowLayout.minimumInteritemSpacing = self.customLayout.minimumInteritemSpacing;
            self.collectionView.collectionViewLayout = flowLayout;
        }
            break;

        case NSOffState:
        {
            self.collectionView.collectionViewLayout = self.customLayout;
        }
            break;

        default:
            break;
    }

    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (IBAction)swapItemClassAction:(id)sender
{
    [self.collectionView reloadData];
}

#pragma mark - NSCollectionViewDataSource methods

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemCount.integerValue;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"mini=%d, path=%@ w=%0.1f", displayMiniItems, indexPath, self.collectionView.frame.size.width);
    
    NSString *identifier;
    NSCollectionViewItem *item;
    
    if (self.useSingleCollectionItemCheckbox.state == NSOnState) {
        identifier = @"DynamicCollectionViewItem";
    } else {
        identifier = displayMiniItems ? @"MiniViewItem" : @"LargeViewItem";
    }
    item = [collectionView makeItemWithIdentifier:identifier
                                     forIndexPath:indexPath];
    NSAssert(item != nil, @"Could not make NSCollectionViewItem.");

    // populate the specifics of each view here

    item.textField.stringValue = [NSString stringWithFormat:@"Item %lu", [indexPath indexAtPosition:1]];

    return item;
}

#pragma mark - NSCollectionViewFlowLayout methods

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // hard coded here, but would be better based on "DynamicCollectionViewItem" object
    if (displayMiniItems)
        return NSMakeSize(100, 222); // w, h
    else
        return NSMakeSize(250, 393);
}

- (NSEdgeInsets)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (displayMiniItems) {
        //return NSEdgeInsetsMake(20, 20, 20, 20);
        return NSEdgeInsetsMake(5, 5, 5, 5);
    }
    else
        return NSEdgeInsetsMake(20, 20, 20, 20);
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self) {
        if ([keyPath isEqualToString:@"itemCount"]) {
            [self.collectionView reloadData];
        }
    }
}

@end
