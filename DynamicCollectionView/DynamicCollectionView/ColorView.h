//
//  ColorView.h
//  DynamicCollectionView
//
//  Created by Demitri Muna on 4/9/19.
//

#import <Cocoa/Cocoa.h>

//IB_DESIGNABLE

NS_ASSUME_NONNULL_BEGIN

@interface ColorView : NSView

@property (nonatomic, strong) IBInspectable NSColor *backgroundColor;

@end

NS_ASSUME_NONNULL_END
