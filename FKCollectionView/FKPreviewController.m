//
//  FKPreviewController.m
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2016/01/23.
//  Copyright © 2016年 Fromkk. All rights reserved.
//

#import "FKPreviewController.h"
#import "FKPreviewAnimator.h"

@interface FKPreviewController () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIBarButtonItem *closeButton;

- (void)onCloseButtonDidTapped:(UIBarButtonItem *)closeButton;

@end

@implementation FKPreviewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        self.image = image;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.leftBarButtonItem = self.closeButton;
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.imageView];
    
    self.imageView.image = self.image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    
    self.imageView.frame = self.view.bounds;
    self.scrollView.contentSize = self.imageView.frame.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - event

- (void)onCloseButtonDidTapped:(UIBarButtonItem *)closeButton
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - scrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - element

- (UIScrollView *)scrollView
{
    if (_scrollView)
    {
        return _scrollView;
    }
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 5.0;
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (_imageView)
    {
        return _imageView;
    }
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    return _imageView;
}

- (UIBarButtonItem *)closeButton
{
    if (_closeButton)
    {
        return _closeButton;
    }
    
    _closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onCloseButtonDidTapped:)];
    return _closeButton;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    if (_imageView)
    {
        _imageView.image = image;
    }
}

#pragma mark - dealloc

- (void)dealloc
{
    self.navigationItem.leftBarButtonItem = nil;
    
    _closeButton = nil;
    
    _image = nil;
    
    [_imageView removeFromSuperview];
    _imageView = nil;
    
    [_scrollView removeFromSuperview];
    _scrollView = nil;
}

@end
