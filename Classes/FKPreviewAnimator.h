//
//  FKPreviewAnimator.h
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2016/01/23.
//  Copyright © 2016年 Fromkk. All rights reserved.
//

@import UIKit;

@protocol FKPreviewAnimatorDelegate <NSObject>

- (NSIndexPath *)selectedIndexPath;
- (CGRect)fromRectWithSelectedIndex:(NSIndexPath *)indexPath;
- (UIImage *)selectedImageWithSelectedIndexPath:(NSIndexPath *)indexPath;

@end

@interface FKPreviewAnimator : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic) id <FKPreviewAnimatorDelegate> delegate;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)sharedAnimatorWithDelegate:(id <FKPreviewAnimatorDelegate>)delegate;

+ (CGRect)imageViewFrameWithImage:(UIImage *)image fromSuperViewSize:(CGSize)superViewSize;

@end
