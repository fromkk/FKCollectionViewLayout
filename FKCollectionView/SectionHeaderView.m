//
//  SectionHeaderView.m
//  FKCollectionView
//
//  Created by Ueoka Kazuya on 2016/01/03.
//  Copyright © 2016年 Fromkk. All rights reserved.
//

#import "SectionHeaderView.h"

@interface SectionHeaderView ()
{
    BOOL SectionHeaderView_setted;
}

- (void)SectionHeaderView_commonInit;

@end

@implementation SectionHeaderView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self SectionHeaderView_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self SectionHeaderView_commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self SectionHeaderView_commonInit];
    }
    
    return self;
}

- (void)SectionHeaderView_commonInit
{
    if (!SectionHeaderView_setted)
    {
        self.backgroundColor = [UIColor redColor];
        
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
        
        SectionHeaderView_setted = YES;
    }
}

@end
