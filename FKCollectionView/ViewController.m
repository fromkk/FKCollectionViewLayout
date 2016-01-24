//
//  ViewController.m
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2015/12/28.
//  Copyright © 2015年 Fromkk. All rights reserved.
//

#import "ViewController.h"
#import "FKCollectionViewLayout.h"
#import "FKImageCollectionViewCell.h"
//#import "SectionHeaderView.h"
//#import "SectionFooterView.h"
#import "FKPreviewController.h"
#import "FKPreviewAnimator.h"

@import Photos;

static NSString * const CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FKCollectionViewLayoutDelegate, FKPreviewAnimatorDelegate>
{
    NSArray <NSMutableArray *> *sizes;
    NSIndexPath *selectedIndexPath;
}

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) PHFetchResult *fetchResult;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sizes = @[@[]];
    
    void (^reload)() = ^{
        PHAssetCollection *cameraRollCollection = [[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil] firstObject];
        _fetchResult = [PHAsset fetchAssetsInAssetCollection:cameraRollCollection options:nil];
        __block NSMutableArray *tmp = [NSMutableArray array];
        [_fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat maxSize = [UIScreen mainScreen].bounds.size.width;
            CGFloat aspect, width, height;
            
            if (asset.pixelWidth > asset.pixelHeight)
            {
                aspect = maxSize / (CGFloat)asset.pixelWidth;
                width = maxSize;
                height = asset.pixelHeight * aspect;
            } else
            {
                aspect = maxSize / (CGFloat)asset.pixelHeight;
                height = maxSize;
                width = asset.pixelWidth * aspect;
            }
            
            [tmp insertObject:NSStringFromCGSize(CGSizeMake(width, height)) atIndex:idx];
        }];
        sizes = @[tmp];
        
        tmp = nil;
        
        [self.collectionView reloadData];
    };
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized)
                {
                    reload();
                } else
                {
                    NSLog(@"deny");
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:
            reload();
            break;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            NSLog(@"deny or restricted");
            break;
        default:
            break;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[FKImageCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
//    [self.collectionView registerClass:[SectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
//    [self.collectionView registerClass:[SectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.collectionView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionView *)collectionView
{
    if (_collectionView)
    {
        return _collectionView;
    }
    
    FKCollectionViewLayout *layout = [FKCollectionViewLayout new];
    layout.minimumInteritemSpacing = 3.0f;
    layout.minimumLineSpacing = 3.0;
    layout.delegate = self;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    return _collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return sizes.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return sizes[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FKImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    PHAsset *asset = _fetchResult[indexPath.row];
    
    CGSize size = CGSizeFromString(sizes[indexPath.section][indexPath.row]);
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result)
        {
            cell.imageView.image = result;
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FKImageCollectionViewCell *cell = (FKImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    selectedIndexPath = indexPath;
    
    FKPreviewController *previewController = [[FKPreviewController alloc] initWithImage:cell.imageView.image];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:previewController];
    navigationController.transitioningDelegate = [FKPreviewAnimator sharedAnimatorWithDelegate:self];
    navigationController.modalTransitionStyle = UIModalPresentationCustom;
    [self presentViewController:navigationController animated:YES completion:nil];
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
//    {
//        SectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
//        headerView.label.text = [NSString stringWithFormat:@"%ld header", indexPath.section];
//        return headerView;
//    } else
//    {
//        SectionFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
//        footerView.label.text = [NSString stringWithFormat:@"%ld footer", indexPath.section];
//        return footerView;
//    }
//}

#pragma mark - FKCollectionViewLayoutDelegate

- (CGSize)layoutSizeWithIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeFromString(sizes[indexPath.section][indexPath.row]);
}

#pragma mark - FKPreviewAnimatorDelegate

- (NSIndexPath *)selectedIndexPath
{
    return selectedIndexPath;
}

- (UIImage *)selectedImageWithSelectedIndexPath:(NSIndexPath *)indexPath
{
    FKImageCollectionViewCell *cell = (FKImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.imageView.image;
}

- (CGRect)fromRectWithSelectedIndex:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    return [self.view convertRect:attribute.frame fromView:self.collectionView];
}

@end
