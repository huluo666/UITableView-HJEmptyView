//
//  UITableView+HJEmptyView.m
//  AutoCoding
//
//  Created by luo.h on 16/1/20.
//  Copyright © 2016年 PCOnline. All rights reserved.
//

#import "UITableView+HJEmptyView.h"
#import <objc/runtime.h>

static const NSString *HJEmptyViewKey = @"HJEmptyViewAssociatedKey";

/**
 *  Method swizzle
 *
 *  @param c    Class
 *  @param orig system @selector
 *  @param new  new    @selector
 */
void HJ_swizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}


@implementation UITableView (HJEmptyView)

+ (void)load{
    // Method switching should be guaranteed and will only be executed once in the program.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class c = [UITableView class];
        HJ_swizzle(c, @selector(reloadData), @selector(HJ_reloadData));
        HJ_swizzle(c, @selector(layoutSubviews), @selector(HJ_layoutSubviews));
    });
}



#pragma mark Properties
- (BOOL)HJ_hasRowsToDisplay;
{
    NSUInteger numberOfRows = 0;
    for (NSInteger sectionIndex = 0; sectionIndex < self.numberOfSections; sectionIndex++) {
        numberOfRows += [self numberOfRowsInSection:sectionIndex];
    }
    return (numberOfRows > 0);
}



#pragma mark-- Updating EmptyView
- (void)HJ_updateEmptyView;
{
    UIView *emptyView = self.HJ_emptyView;
    if (!emptyView) return;
    
    if (emptyView.superview != self) {
        [self addSubview:emptyView];
    }
    
    // setup empty view frame
    CGRect frame = self.bounds;
    frame.origin = CGPointMake(0, 0);
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(CGRectGetHeight(self.tableHeaderView.frame), 0, 0, 0));
    frame.size.height -= self.contentInset.top;
    emptyView.frame = frame;
    emptyView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    // need to show ?
    BOOL emptyViewShouldBeShown = (self.HJ_hasRowsToDisplay == NO);
    
    // show / hide empty view
    emptyView.hidden = !emptyViewShouldBeShown;
}


#pragma mark-- Swizzle methods
- (void)HJ_reloadData;
{
    //Call system reloadData
    [self HJ_reloadData];
    [self HJ_updateEmptyView];
}

- (void)HJ_layoutSubviews;
{
    [self HJ_layoutSubviews];
    [self HJ_updateEmptyView];
}


#pragma mark--- AssociatedObject
@dynamic HJ_emptyView;
- (UIView *)HJ_emptyView;
{
    return objc_getAssociatedObject(self, &HJEmptyViewKey);
}

- (void)setHJ_emptyView:(UIView *)value;
{
    if (self.HJ_emptyView.superview) {
        [self.HJ_emptyView removeFromSuperview];
    }
    objc_setAssociatedObject(self, &HJEmptyViewKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self HJ_updateEmptyView];
}

@end