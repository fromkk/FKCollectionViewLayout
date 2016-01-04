//
//  FKCollectionViewLayout.h
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2015/12/28.
//  Copyright © 2015年 Fromkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FKCollectionViewLayoutDelegate;

typedef NS_ENUM(NSInteger, FKCollectionViewLayoutType)
{
    FKCollectionViewLayoutTypeVHH = 1,
    FKCollectionViewLayoutTypeHHV,
    FKCollectionViewLayoutTypeHHH,
    FKCollectionViewLayoutTypeVVV,
    FKCollectionViewLayoutTypeHV,
    FKCollectionViewLayoutTypeVV,
    FKCollectionViewLayoutTypeVH,
    FKCollectionViewLayoutTypeHH,
    FKCollectionViewLayoutTypeV,
    FKCollectionViewLayoutTypeH
};

@interface FKCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic) id <FKCollectionViewLayoutDelegate> delegate;

@end

@protocol FKCollectionViewLayoutDelegate <NSObject>

@required
- (CGSize)layoutSizeWithIndexPath:(NSIndexPath *)indexPath;

@end