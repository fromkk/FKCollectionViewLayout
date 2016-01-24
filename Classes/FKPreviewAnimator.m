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
    CGPoint lastPoint;
}

@property (nonatomic) BOOL presenting;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIView *backgroundView;

@property (nonatomic) id <UIViewControllerContextTransitioning> currentContext;
@property (nonatomic) UIPanGestureRecognizer *panGesture;

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
    [containerView addSubview:self.backgroundView];
    self.backgroundView.frame = containerView.bounds;
    self.backgroundView.alpha = 0.0;
    
    self.imageView.image = [self.delegate selectedImageWithSelectedIndexPath:[self.delegate selectedIndexPath]];
    self.imageView.frame = [self.delegate fromRectWithSelectedIndex:[self.delegate selectedIndexPath]];
    [containerView addSubview:self.imageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.imageView.frame = [[self class] imageViewFrameWithImage:self.imageView.image fromSuperViewSize:[UIScreen mainScreen].bounds.size];
        self.backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        [self transitionCompletion:transitionContext];
        
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        if ([toViewController isKindOfClass:[UINavigationController class]])
        {
            [(UINavigationController *)toViewController visibleViewController].view.userInteractionEnabled = YES;
            [[(UINavigationController *)toViewController visibleViewController].view addGestureRecognizer:self.panGesture];
        } else
        {
            toViewController.view.userInteractionEnabled = YES;
            [toViewController.view addGestureRecognizer:self.panGesture];
        }
        
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
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.imageView.frame = [self.delegate fromRectWithSelectedIndex:[self.delegate selectedIndexPath]];
        self.backgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        [self transitionCompletion:transitionContext];
        
        [fromViewController.view removeGestureRecognizer:self.panGesture];
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
    } else
    {
        self.delegate = nil;
    }
    [transitionContext completeTransition:YES];
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
    
    void (^cancelToViewController)() = ^{
        [UIView animateWithDuration:[self transitionDuration:_currentContext] animations:^{
            CGRect frame = toViewController.view.frame;
            frame.origin = CGPointZero;
            toViewController.view.frame = frame;
        }];
    };
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastPoint = [panGesture locationInView:toViewController.view];
            startPoint = lastPoint;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currentPoint = [panGesture locationInView:[[UIApplication sharedApplication] keyWindow]];
            CGPoint diffPoint = CGPointMake(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y);
            
            CGRect frame = toViewController.view.frame;
            frame.origin.y += diffPoint.y;
            toViewController.view.frame = frame;
            
            lastPoint = currentPoint;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            cancelToViewController();
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGFloat diff = fabs(startPoint.y - lastPoint.y);
            if (previewDismissBorder <= diff)
            {
                [toViewController dismissViewControllerAnimated:YES completion:nil];
            } else
            {
                cancelToViewController();
            }
        }
            break;
        default:
            break;
    }
}

@end
