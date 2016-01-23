//
//  FKPreviewAnimator.m
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2016/01/23.
//  Copyright © 2016年 Fromkk. All rights reserved.
//

#import "FKPreviewAnimator.h"

@interface FKPreviewAnimator ()

@property (nonatomic) BOOL presenting;
@property (nonatomic) UIImageView *imageView;

@end

@implementation FKPreviewAnimator

#pragma mark - shared

+ (instancetype)sharedAnimatorWithDelegate:(id<FKPreviewAnimatorDelegate>)delegate
{
    static FKPreviewAnimator *sharedAnimator = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedAnimator = [[self alloc] init];
    });
    sharedAnimator.delegate = delegate;
    
    return sharedAnimator;
}

#pragma mark - element

- (UIImageView *)imageView
{
    if (_imageView)
    {
        return _imageView;
    }
    
    _imageView = [[UIImageView alloc] init];
    return _imageView;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.presenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presenting = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (_presenting)
    {
        [self presentTransitionWithTransitionContext:transitionContext];
    } else
    {
        [self dismissTransitionWithTransitionContext:transitionContext];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.33;
}

- (void)presentTransitionWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [self.delegate selectedImageWithSelectedIndexPath:[self.delegate selectedIndexPath]];
    self.imageView.frame = [self.delegate fromRectWithSelectedIndex:[self.delegate selectedIndexPath]];
    [containerView addSubview:self.imageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.imageView.frame = [UIScreen mainScreen].bounds;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        [self transitionCompletion:transitionContext];
    }];
}

- (void)dismissTransitionWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [containerView addSubview:toViewController.view];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = [self.delegate selectedImageWithSelectedIndexPath:[self.delegate selectedIndexPath]];
    self.imageView.frame = [UIScreen mainScreen].bounds;
    [containerView addSubview:self.imageView];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [fromViewController.view removeFromSuperview];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.imageView.frame = [self.delegate fromRectWithSelectedIndex:[self.delegate selectedIndexPath]];
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        [self transitionCompletion:transitionContext];
    }];
}

- (void)transitionCompletion:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (_presenting)
    {
        [containerView addSubview:toViewController.view];
    } else
    {
        self.delegate = nil;
    }
    [transitionContext completeTransition:YES];
}

@end
