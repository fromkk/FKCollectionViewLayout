//
//  SectionFooterView.m
//  FKCollectionView
//
//  Created by Ueoka Kazuya on 2016/01/03.
//  Copyright © 2016年 Fromkk. All rights reserved.
//

#import "SectionFooterView.h"

@interface SectionFooterView ()
{
    BOOL SectionFooterView_setted;
}

- (void)SectionFooterView_commonInit;

@end

@implementation SectionFooterView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self SectionFooterView_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self SectionFooterView_commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self SectionFooterView_commonInit];
    }
    
    return self;
}

- (void)SectionFooterView_commonInit
{
    if (!SectionFooterView_setted)
    {
        self.backgroundColor = [UIColor blueColor];
        
        self.label = [UILabel new];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:16.0],
                               [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:16.0],
                               [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.label attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]
                               ]];
        [self addSubview:self.label];
        
        SectionFooterView_setted = YES;
    }
}

@end
