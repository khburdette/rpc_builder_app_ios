//
//  UIView+Resize.m
//  RPC Builder
//

#import "UIView+Util.h"

@implementation UIView (Util)

- (void)resizeToFit:(CGSize)size {
    CGSize sizeToFit = [self sizeThatFits:size];
    
    CGFloat maxHeight = sizeToFit.height;
    CGFloat maxWidth = sizeToFit.width;
    
    if (self.subviews.count) {
        for (UIView* subview in self.subviews) {
            maxHeight = MAX(maxHeight, CGRectGetMaxY(subview.frame));
            maxWidth = MAX(maxWidth, CGRectGetMaxX(subview.frame));
        }
    }
    
    if (maxWidth > size.width) {
        maxWidth = size.width;
    }
    
    CGRect sizeRect = self.frame;
    sizeRect.size.width = maxWidth;
    sizeRect.size.height = maxHeight;
    self.frame = sizeRect;
}

- (void)rightAlignmentWithReferenceRect:(CGRect)referenceRect {
    [self sizeToFit];
    CGFloat width = [RBDeviceInformation deviceWidth] - CGRectGetWidth(referenceRect) - (kViewSpacing * 3.0);
    CGRect adjustedFrame = CGRectMake(CGRectGetMaxX(referenceRect) + kViewSpacing,
                                      CGRectGetMinY(referenceRect),
                                      width,
                                      MAX(kMinViewHeight, CGRectGetHeight(self.bounds)));
    self.frame = adjustedFrame;
    
    // This will happen only when a UIView's width cannot grow (i.e. UISwitch)
    if (CGRectGetWidth(self.bounds) < width) {
        width = CGRectGetWidth(self.bounds);
        adjustedFrame.origin.x = [RBDeviceInformation deviceWidth] - width - (kViewSpacing * 2.0);
        adjustedFrame.size.width = width;
        self.frame = adjustedFrame;
    }
}

- (void)bottomAlignmentWithReferenceRect:(CGRect)referenceRect {
    [self sizeToFit];
    CGFloat width = [RBDeviceInformation deviceWidth] - (kViewSpacing * 2.0);
    CGRect adjustedFrame = CGRectMake(CGRectGetMinX(referenceRect),
                                      CGRectGetMaxY(referenceRect) + kViewSpacing,
                                      width,
                                      MAX(kMinViewHeight, CGRectGetHeight(self.bounds)));
    self.frame = adjustedFrame;
}

- (void)copyParentConstraintsToView:(UIView*)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray* removeConstraints = [NSMutableArray array];
    NSMutableArray* addConstraints = [NSMutableArray array];
    
    for (NSLayoutConstraint* constraint in self.superview.constraints) {
        if (constraint.firstItem == self || constraint.secondItem == self) {
            id firstItem = nil;
            id secondItem = nil;
            if (constraint.firstItem != nil) {
                firstItem = (constraint.firstItem == self) ? view : constraint.firstItem;
            }
            if (constraint.secondItem != nil) {
                secondItem = (constraint.secondItem == self) ? view : constraint.secondItem;
            }
            
            NSLayoutConstraint* newConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                             attribute:constraint.firstAttribute
                                                                             relatedBy:constraint.relation
                                                                                toItem:secondItem
                                                                             attribute:constraint.secondAttribute
                                                                            multiplier:constraint.multiplier
                                                                              constant:constraint.constant];
            newConstraint.priority = constraint.priority;
            newConstraint.active = constraint.isActive;
            
            [addConstraints addObject:newConstraint];
            [removeConstraints addObject:constraint];
        }
    }
    
    [self.superview removeConstraints:removeConstraints];
    [self.superview addConstraints:addConstraints];
    
}

@end
