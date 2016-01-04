//
//  FKImageCollectionViewCell.m
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2015/12/28.
//  Copyright © 2015年 Fromkk. All rights reserved.
//

#import "FKImageCollectionViewCell.h"

@interface FKImageCollectionViewCell ()
{
    BOOL FKImageCollectionViewCell_didSet;
}

- (void)FKImageCollectionViewCell_commonInit;

@end

@implementation FKImageCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self FKImageCollectionViewCell_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self FKImageCollectionViewCell_commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self FKImageCollectionViewCell_commonInit];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self FKImageCollectionViewCell_commonInit];
}

- (void)FKImageCollectionViewCell_commonInit
{
    if (FKImageCollectionViewCell_didSet)
    {
        return;
    }
    
    self.imageView = [UIImageView new];
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    
    FKImageCollectionViewCell_didSet = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end
