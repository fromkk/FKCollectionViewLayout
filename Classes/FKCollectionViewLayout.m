//
//  FKCollectionViewLayout.m
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2015/12/28.
//  Copyright © 2015年 Fromkk. All rights reserved.
//

#import "FKCollectionViewLayout.h"

#define HorizontalSize(x) x.width >= x.height
#define VerticalSize(x) x.width <= x.height

@interface FKCollectionViewLayout ()
{
    CGSize contentSize;
    NSMutableDictionary *attributesDictionary;
    NSMutableArray *headerAttributes;
    NSMutableArray *footerAttributes;
    
    FKCollectionViewLayoutType lastLayoutType;
    CGFloat lastHeight;
    NSInteger continuesCount;
}

- (NSInteger)_layout:(CGSize)firstSize withSection:(NSInteger)section row:(NSInteger)row;
- (NSInteger)_layout:(CGSize)firstSize secondSize:(CGSize)secondSize withSection:(NSInteger)section row:(NSInteger)row;
- (NSInteger)_layout:(CGSize)firstSize secondSize:(CGSize)secondSize thirdSize:(CGSize)thirdSize withSection:(NSInteger)section row:(NSInteger)row;

@end

@implementation FKCollectionViewLayout

- (void)prepareLayout
{
    attributesDictionary = [NSMutableDictionary dictionary];
    headerAttributes = [NSMutableArray array];
    footerAttributes = [NSMutableArray array];
    
    NSAssert([self.delegate respondsToSelector:@selector(layoutSizeWithIndexPath:)], @"delegate not setted.");
    
    CGSize firstSize, secondSize, thirdSize;
    CGFloat width = self.collectionView.frame.size.width;
    lastHeight = 0;
    NSInteger row, rows;
    
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++)
    {
        //header
        if (!CGSizeEqualToSize(self.headerReferenceSize, CGSizeZero))
        {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            attributes.frame = CGRectMake(0.0, lastHeight, width, self.headerReferenceSize.height);
            [headerAttributes addObject:attributes];
            attributes = nil;
            
            lastHeight += self.headerReferenceSize.height;
        }
        
        continuesCount = 0;
        row = 0;
        rows = [self.collectionView numberOfItemsInSection:section];
        
        while (true)
        {
            if (row >= rows)
            {
                break;
            }
            
            if (rows >= row + 3)
            {
                firstSize  = [self.delegate layoutSizeWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                secondSize = [self.delegate layoutSizeWithIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:section]];
                thirdSize  = [self.delegate layoutSizeWithIndexPath:[NSIndexPath indexPathForRow:row + 2 inSection:section]];
                
                row += [self _layout:firstSize secondSize:secondSize thirdSize:thirdSize withSection:(NSInteger)section row:(NSInteger)row];
                continue;
            } else if (rows >= row + 2)
            {
                firstSize  = [self.delegate layoutSizeWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                secondSize = [self.delegate layoutSizeWithIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:section]];
                
                row += [self _layout:firstSize secondSize:secondSize withSection:(NSInteger)section row:(NSInteger)row];
                continue;
            } else if (rows >= row + 1)
            {
                firstSize  = [self.delegate layoutSizeWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                
                row += [self _layout:firstSize withSection:(NSInteger)section row:(NSInteger)row];
                continue;
            }
        }
        
        //footer
        if (!CGSizeEqualToSize(self.footerReferenceSize, CGSizeZero))
        {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            attributes.frame = CGRectMake(0.0, lastHeight, width, self.footerReferenceSize.height);
            [footerAttributes addObject:attributes];
            attributes = nil;
            
            lastHeight += self.footerReferenceSize.height;
        }
    }
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.frame.size.width, lastHeight);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray <UICollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++)
    {
        UICollectionViewLayoutAttributes *header = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        if (nil != header && CGRectIntersectsRect(rect, header.frame))
        {
            [result addObject:header];
        }
        
        for (NSInteger row = 0; row < [self.collectionView numberOfItemsInSection:section]; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame))
            {
                [result addObject:attributes];
            }
        }
        
        UICollectionViewLayoutAttributes *footer = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        if (nil != footer && CGRectIntersectsRect(rect, footer.frame))
        {
            [result addObject:footer];
        }
    }
    
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [attributesDictionary objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader])
    {
        return headerAttributes.count > indexPath.section ? headerAttributes[indexPath.section] : nil;
    } else
    {
        return footerAttributes.count > indexPath.section ? footerAttributes[indexPath.section] : nil;
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

#pragma mark - layout

/**
 * 3列レイアウト
 */
- (NSInteger)_layout:(CGSize)firstSize secondSize:(CGSize)secondSize thirdSize:(CGSize)thirdSize withSection:(NSInteger)section row:(NSInteger)row
{
    CGFloat width = self.collectionView.frame.size.width;
    CGRect firstRect, secondRect, thirdRect;
    CGFloat marginWidth = self.minimumInteritemSpacing / 2.0;
    CGFloat marginHeight = self.minimumLineSpacing / 2.0;
    UICollectionViewLayoutAttributes *attribute;
    NSIndexPath *indexPath;
    
    if (VerticalSize(firstSize) && HorizontalSize(secondSize) && HorizontalSize(thirdSize))
    {
        //縦・横・横
        firstRect  = CGRectMake(0.0, lastHeight, width / 3.0, width / 3.0 * 2.0);
        secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, width - CGRectGetWidth(firstRect), CGRectGetHeight(firstRect) / 2.0);
        thirdRect  = CGRectMake(secondRect.origin.x, CGRectGetMaxY(secondRect), CGRectGetWidth(secondRect), CGRectGetHeight(secondRect));
        
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(secondRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 2 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(thirdRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        lastHeight = CGRectGetMaxY(thirdRect);
        lastLayoutType = FKCollectionViewLayoutTypeVHH;
    } else if (HorizontalSize(firstSize) && HorizontalSize(secondSize) && VerticalSize(thirdSize))
    {
        //横・横・縦
        firstRect  = CGRectMake(0.0, lastHeight, width / 3.0 * 2.0, width / 3.0);
        secondRect = CGRectMake(0.0, CGRectGetMaxY(firstRect), CGRectGetWidth(firstRect), CGRectGetHeight(firstRect));
        thirdRect  = CGRectMake(CGRectGetMaxX(secondRect), lastHeight, width / 3.0, width / 3.0 * 2.0);
        
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(secondRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 2 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(thirdRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        lastHeight = CGRectGetMaxY(thirdRect);
        lastLayoutType = FKCollectionViewLayoutTypeHHV;
    } else if (VerticalSize(firstSize) && VerticalSize(secondSize) && VerticalSize(thirdSize))
    {
        //縦・縦・縦
        if (lastLayoutType != FKCollectionViewLayoutTypeVVV)
        {
            continuesCount = 0;
        } else
        {
            continuesCount++;
        }
        
        switch (continuesCount % 4) {
            case 0:
                firstRect  = CGRectMake(0.0, lastHeight, width / 3.0 * 2.0, width / 3.0 * 2.0);
                secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, width / 3.0, width / 3.0);
                thirdRect  = CGRectMake(secondRect.origin.x, CGRectGetMaxY(secondRect), CGRectGetWidth(secondRect), CGRectGetHeight(secondRect));
                break;
            case 1:
            case 3:
                firstRect  = CGRectMake(0.0, lastHeight, width / 3, width / 3);
                secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, CGRectGetWidth(firstRect), CGRectGetHeight(firstRect));
                thirdRect  = CGRectMake(CGRectGetMaxX(secondRect), lastHeight, CGRectGetWidth(firstRect), CGRectGetHeight(firstRect));
                break;
            case 2:
                firstRect  = CGRectMake(0.0, lastHeight, width / 3.0, width / 3.0);
                secondRect = CGRectMake(0.0, CGRectGetMaxY(firstRect), width / 3.0, width / 3.0);
                thirdRect  = CGRectMake(CGRectGetMaxX(secondRect), lastHeight, width / 3.0 * 2.0, width / 3.0 * 2.0);
                break;
            default:
                break;
        }

        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(secondRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 2 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(thirdRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        lastHeight = CGRectGetMaxY(thirdRect);
        lastLayoutType = FKCollectionViewLayoutTypeVVV;
    } else if (HorizontalSize(firstSize) && HorizontalSize(secondSize) && HorizontalSize(thirdSize))
    {
        //横・横・横
        if (lastLayoutType != FKCollectionViewLayoutTypeHHH)
        {
            continuesCount = 0;
        } else
        {
            continuesCount++;
        }
        
        switch (continuesCount % 4) {
            case 0:
                firstRect  = CGRectMake(0.0, lastHeight, width / 3.0 * 2.0, width / 3.0 * 2.0);
                secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, width / 3.0, width / 3.0);
                thirdRect  = CGRectMake(secondRect.origin.x, CGRectGetMaxY(secondRect), CGRectGetWidth(secondRect), CGRectGetHeight(secondRect));
                break;
            case 1:
            case 3:
                firstRect  = CGRectMake(0.0, lastHeight, width / 3, width / 3);
                secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, CGRectGetWidth(firstRect), CGRectGetHeight(firstRect));
                thirdRect  = CGRectMake(CGRectGetMaxX(secondRect), lastHeight, CGRectGetWidth(firstRect), CGRectGetHeight(firstRect));
                break;
            case 2:
                firstRect  = CGRectMake(0.0, lastHeight, width / 3.0, width / 3.0);
                secondRect = CGRectMake(0.0, CGRectGetMaxY(firstRect), width / 3.0, width / 3.0);
                thirdRect  = CGRectMake(CGRectGetMaxX(secondRect), lastHeight, width / 3.0 * 2.0, width / 3.0 * 2.0);
                break;
            default:
                break;
        }
        
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(secondRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 2 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(thirdRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        lastHeight = CGRectGetMaxY(thirdRect);
        lastLayoutType = FKCollectionViewLayoutTypeHHH;
        
    } else
    {
        return [self _layout:firstSize secondSize:secondSize withSection:(NSInteger)section row:(NSInteger)row];
    }
    
    return 3;
}

/**
 * 2列レイアウト
 */
- (NSInteger)_layout:(CGSize)firstSize secondSize:(CGSize)secondSize withSection:(NSInteger)section row:(NSInteger)row
{
    CGFloat width = self.collectionView.frame.size.width;
    CGRect firstRect, secondRect;
    CGFloat marginWidth = self.minimumInteritemSpacing / 2.0;
    CGFloat marginHeight = self.minimumLineSpacing / 2.0;
    UICollectionViewLayoutAttributes *attribute;
    NSIndexPath *indexPath;
    
    if ( HorizontalSize(firstSize) && VerticalSize(secondSize) )
    {
        //横・縦
        firstRect = CGRectMake(0.0, lastHeight, width / 3.0 * 2.0, width / 3.0);
        secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, width / 3.0, width / 3.0);
        
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(secondRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        lastHeight = CGRectGetMaxY(secondRect);
        lastLayoutType = FKCollectionViewLayoutTypeHV;
    } else if ( VerticalSize(firstSize) && VerticalSize(secondSize) )
    {
        //縦・縦
        firstRect = CGRectMake(0.0, lastHeight, width / 2.0, width / 3.0 * 2.0);
        secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, CGRectGetWidth(firstRect), CGRectGetHeight(firstRect));
        
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(secondRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        lastHeight = CGRectGetMaxY(secondRect);
        
        lastLayoutType = FKCollectionViewLayoutTypeVV;
    } else if ( VerticalSize(firstSize) && HorizontalSize(secondSize) )
    {
        //縦・横
        firstRect = CGRectMake(0.0, lastHeight, width / 3.0, width / 3.0 * 2.0);
        secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, width / 3.0 * 2, width / 3.0 * 2.0);
        
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(secondRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        lastHeight = CGRectGetMaxY(secondRect);
        
        lastLayoutType = FKCollectionViewLayoutTypeVH;
    } else
    {
        //横・横
        firstRect = CGRectMake(0.0, lastHeight, width / 2.0, width / 2.0);
        secondRect = CGRectMake(CGRectGetMaxX(firstRect), lastHeight, CGRectGetWidth(firstRect), CGRectGetHeight(firstRect));
        
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = CGRectInset(secondRect, marginWidth, marginHeight);
        [attributesDictionary setObject:attribute forKey:indexPath];
        indexPath = nil, attribute = nil;
        
        lastHeight = CGRectGetMaxY(secondRect);
        lastLayoutType = FKCollectionViewLayoutTypeHH;
    }
    
    return 2;
}

/*
 * 1列レイアウト
 */
- (NSInteger)_layout:(CGSize)firstSize withSection:(NSInteger)section row:(NSInteger)row
{
    CGFloat width = self.collectionView.frame.size.width;
    CGRect firstRect;
    UICollectionViewLayoutAttributes *attribute;
    NSIndexPath *indexPath;
    CGFloat marginWidth = self.minimumInteritemSpacing / 2.0;
    CGFloat marginHeight = self.minimumLineSpacing / 2.0;
    
    if (VerticalSize(firstSize))
    {
        //縦
        firstRect = CGRectMake(0.0, lastHeight, width, width / 3.0 * 2.0);
        
        lastLayoutType = FKCollectionViewLayoutTypeV;
    } else
    {
        //横
        firstRect = CGRectMake(0.0, lastHeight, width, width / 3.0);
        
        lastLayoutType = FKCollectionViewLayoutTypeH;
    }
    indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attribute.frame = CGRectInset(firstRect, marginWidth, marginHeight);
    [attributesDictionary setObject:attribute forKey:indexPath];
    indexPath = nil, attribute = nil;
    
    lastHeight = CGRectGetMaxY(firstRect);
    
    return 1;
}

@end
