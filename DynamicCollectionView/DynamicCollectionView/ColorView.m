//
//  ColorView.m
//  DynamicCollectionView
//
//  Created by Demitri Muna on 4/9/19.
//

#import "ColorView.h"
@import QuartzCore;

@interface ColorView()
@property (nonatomic, strong) NSArray *propertiesToObserve;
- (void)_commonInit;
@end

#pragma mark -

@implementation ColorView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        [self _commonInit];
    }
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.wantsLayer = YES;
    
    self.propertiesToObserve = @[@"backgroundColor"];
    
    for (NSString *property in self.propertiesToObserve) {
        [self addObserver:self
               forKeyPath:property
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }

    self.backgroundColor = [NSColor yellowColor];
}

- (void)dealloc
{
    for (NSString *property in self.propertiesToObserve)
        [self removeObserver:self forKeyPath:property];
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [self.backgroundColor setFill];
    NSRectFill(dirtyRect);
}


#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self) {
        if ([keyPath isEqualToString:@"backgroundColor"]) {
            self.layer.backgroundColor = self.backgroundColor.CGColor;
            self.needsDisplay = YES;
        }
    }
}


@end
