//
//  FKPreviewController.h
//  FKCollectionView
//
//  Created by Kazuya Ueoka on 2016/01/23.
//  Copyright © 2016年 Fromkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKPreviewController : UIViewController

@property (nonatomic) UIImage *image;
@property (nonatomic) NSIndexPath *indexPath;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithImage:(UIImage *)image;

@end
