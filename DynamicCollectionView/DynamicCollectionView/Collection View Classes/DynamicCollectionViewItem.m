//
//  DynamicCollectionViewItem.m
//  DynamicCollectionView
//
//  Created by Demitri Muna on 4/9/19.
//

#import "DynamicCollectionViewItem.h"

@interface DynamicCollectionViewItem()
@property (nonatomic, strong) NSView *currentDetailView;
@property (nonatomic, strong) id collectionViewFrameChangeObserver;
@end

#pragma mark -

@implementation DynamicCollectionViewItem

- (void)awakeFromNib
{
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.miniView.translatesAutoresizingMaskIntoConstraints = NO;
    self.largeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Note: immediately after the view change, connect the 'textField' subview of NSCollectionViewItem to the view we just chose.

    // select initial size based on view width
    if (self.view.frame.size.width < self.largeWidthConstraint.constant) {
        [self makeDetailView:self.miniView];
        self.textField = self.miniViewTextField;
    }
    else {
        [self makeDetailView:self.largeView];
        self.textField = self.largeViewTextField;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    self.view.postsFrameChangedNotifications = YES;
    self.collectionViewFrameChangeObserver = [nc addObserverForName:NSViewFrameDidChangeNotification
                                                             object:self.view
                                                              queue:[NSOperationQueue mainQueue]
                                                         usingBlock:^(NSNotification * _Nonnull note) {

                                                             BOOL isMini = (self.currentDetailView == self.miniView);
                                                             
                                                             BOOL needsMiniView = self.view.frame.size.width < self.largeWidthConstraint.constant;
                                                             
                                                             if (isMini == needsMiniView)
                                                                 return; // no change needed
                                                             
                                                             NSLog(@"item flip (w=%.0f)", self.view.frame.size.width);
                                                             
                                                             if (needsMiniView) {
                                                                 [self makeDetailView:self.miniView];
                                                                 self.textField = self.miniViewTextField;
                                                             } else {
                                                                 [self makeDetailView:self.largeView];
                                                                 self.textField = self.largeViewTextField;
                                                             }

                                                         }
                                              ];
}

- (void)dealloc
{
    // If your app targets iOS 9.0 and later or macOS 10.11 and later, you don't need to unregister an observer in its dealloc method.
    if (floor(NSAppKitVersionNumber) < NSAppKitVersionNumber10_11) {
        if (self.collectionViewFrameChangeObserver)
            [[NSNotificationCenter defaultCenter] removeObserver:self.collectionViewFrameChangeObserver];
    }
    
    [self removeObserver:self forKeyPath:@"textField"];
}

- (void)makeDetailView:(NSView*)newView
{
    if (newView == self.currentDetailView)
        return;
    
    if (self.currentDetailView)
        [self.currentDetailView removeFromSuperview];
    [self.view addSubview:newView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newView]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"newView":newView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:newView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    self.currentDetailView = newView;
}

@end
