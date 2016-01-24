//
//  FKPreviewAnimator.m
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2016/01/23.
//  Copyright © 2016年 Fromkk. All rights reserved.
//

#import "FKPreviewAnimator.h"

static CGFloat const previewDismissBorder = 40.0;

@interface FKPreviewAnimator ()
{
    CGPoint startPoint;
    CGPoint goalPoint;
    CGPoint lastPoint;
    CGPoint currentPoint;
}

@property (nonatomic) BOOL presenting;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIView *backgroundView;

@property (nonatomic) id <UIViewControllerContextTransitioning> currentContext;
@property (nonatomic) UIPanGestureRecognizer *panGesture;

@property (nonatomic) UIPercentDrivenInteractiveTransition *interactiveController;

- (void)onPanGestureDidReceived:(UIPanGestureRecognizer *)panGesture;

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
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    return _imageView;
}

- (UIView *)backgroundView
{
    if (_backgroundView)
    {
        return _backgroundView;
    }
    
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = [UIColor blackColor];
    return _backgroundView;
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

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveController;
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
    return 0.5;
}

- (void)presentTransitionWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    [containerView addGestureRecognizer:self.panGesture];
    
    [containerView addSubview:self.backgroundView];
    self.backgroundView.frame = containerView.bounds;
    self.backgroundView.alpha = 0.0;
    
    self.imageView.image = [self.delegate selectedImageWithSelectedIndexPath:[self.delegate selectedIndexPath]];
    self.imageView.frame = [self.delegate fromRectWithSelectedIndex:[self.delegate selectedIndexPath]];
    [containerView addSubview:self.imageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageView.frame = [[self class] imageViewFrameWithImage:self.imageView.image fromSuperViewSize:[UIScreen mainScreen].bounds.size];
        self.backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        [self transitionCompletion:transitionContext];
        
        _currentContext = transitionContext;
    }];
}

- (void)dismissTransitionWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [containerView addSubview:toViewController.view];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [fromViewController.view removeFromSuperview];
    
    self.backgroundView.alpha = 1.0;
    [containerView addSubview:self.backgroundView];
    self.backgroundView.frame = containerView.bounds;
    
    self.imageView.image = [self.delegate selectedImageWithSelectedIndexPath:[self.delegate selectedIndexPath]];
    CGRect frame = [[self class] imageViewFrameWithImage:self.imageView.image fromSuperViewSize:[UIScreen mainScreen].bounds.size];
    frame.origin.y += fromViewController.view.frame.origin.y;
    
    self.imageView.frame = frame;
    [containerView addSubview:self.imageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageView.frame = [self.delegate fromRectWithSelectedIndex:[self.delegate selectedIndexPath]];
        self.backgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        [self transitionCompletion:transitionContext];
        _currentContext = nil;
    }];
}

- (void)transitionCompletion:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (_presenting)
    {
        [containerView addSubview:toViewController.view];
        [transitionContext completeTransition:YES];
    } else
    {
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        if ([transitionContext transitionWasCancelled])
        {
            UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            [toViewController.view removeFromSuperview];
            
            UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            [containerView addSubview:fromViewController.view];
            
            [containerView addGestureRecognizer:self.panGesture];
        } else
        {
            [fromViewController.view removeGestureRecognizer:self.panGesture];
            self.delegate = nil;
        }
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }
}

#pragma mark - imageView frame

+ (CGRect)imageViewFrameWithImage:(UIImage *)image fromSuperViewSize:(CGSize)superViewSize
{
    CGRect imageViewFrame = CGRectZero;
    
    CGFloat aspectWidth = superViewSize.width / image.size.width;
    CGFloat aspectHeight = superViewSize.height / image.size.height;
    
    if (aspectWidth < aspectHeight)
    {
        imageViewFrame.size = CGSizeMake(superViewSize.width, image.size.height * aspectWidth);
    } else
    {
        imageViewFrame.size = CGSizeMake(image.size.width * aspectHeight, superViewSize.width);
    }
    
    imageViewFrame.origin = CGPointMake((superViewSize.width - imageViewFrame.size.width) / 2.0, (superViewSize.height - imageViewFrame.size.height) / 2.0);
    
    return imageViewFrame;
}

#pragma mark - panGesture

- (UIPanGestureRecognizer *)panGesture
{
    if (_panGesture)
    {
        return _panGesture;
    }
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureDidReceived:)];
    return _panGesture;
}

- (void)onPanGestureDidReceived:(UIPanGestureRecognizer *)panGesture
{
    if (nil == _currentContext)
    {
        return;
    }
    
    UIViewController *toViewController = [_currentContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastPoint = [panGesture locationInView:[UIApplication sharedApplication].keyWindow];
            startPoint = lastPoint;
            goalPoint = [self.delegate fromRectWithSelectedIndex:[self.delegate selectedIndexPath]].origin;
            currentPoint = toViewController.view.frame.origin;
            
            self.interactiveController = [[UIPercentDrivenInteractiveTransition alloc] init];
            [toViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint tmpPoint = [panGesture locationInView:[UIApplication sharedApplication].keyWindow];
            CGFloat diff = tmpPoint.y - lastPoint.y;
            currentPoint.y += diff;
            
            CGFloat transitionProgress = fabs(currentPoint.y / goalPoint.y);
            
            [self.interactiveController updateInteractiveTransition:fabs(transitionProgress)];
            
            lastPoint = tmpPoint;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self.interactiveController cancelInteractiveTransition];
            self.interactiveController = nil;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGFloat diff = fabs(startPoint.y - lastPoint.y);
            if (previewDismissBorder <= diff)
            {
                [self.interactiveController finishInteractiveTransition];
                self.interactiveController = nil;
            } else
            {
                [self.interactiveController cancelInteractiveTransition];
                self.interactiveController = nil;
            }
        }
            break;
        default:
            break;
    }
}

@end
