//
//  ViewController.m
//  SaveImg2Album
//
//  Created by 辉贾 on 16/3/30.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ALAssetsLibrary+RJSavePhotoAlubm.h"
#import "MBProgressHUD.h"

@interface ViewController ()<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, UIAlertViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign)NSInteger indexRow;
@property (nonatomic, strong)MBProgressHUD *hud;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"美女";
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"item"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation {
    CHTCollectionViewWaterfallLayout *layout =
    (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3;
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"item"
                                                                           forIndexPath:indexPath];
    
    ItemModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    NSString *imgUrlString = model.imageUrl;
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrlString] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            if (!CGSizeEqualToSize(model.imageSize, image.size)) {
                model.imageSize = image.size;
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.indexRow = indexPath.row;
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"确定要将该美女保存到手机的美女相册吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        ItemModel *model = self.dataArray[self.indexRow];
        [self saveImg:model.imageUrl];
    }
}

- (void)saveImg:(NSString *)imgURL {
    SDWebImageManager * manager = [SDWebImageManager sharedManager];
    
    NSURL * url = [NSURL URLWithString: imgURL];
    [manager downloadImageWithURL: url options: 0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"%g", receivedSize * 1.0 / expectedSize);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (nil != error) {
            [self showText:@"保存失败"];
            return;
        }
        
        NSString * key = [manager cacheKeyForURL: imageURL];
        
        /* 存相册前,要先清一下内存缓存,否则会导致内存无法释放.[缓存机制和相册写入机制的内部冲突,源码不可见,真实原因未知] */
        [manager.imageCache removeImageForKey:key fromDisk: NO withCompletion:^{
            ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
            [library saveImg:image toAlbum:@"美女" withCompletionBlock:^(NSURL *assetUrl, NSError *error) {
                if (!error) {
                    [self showText:@"保存成功"];
                } else {
                    [self showText:@"保存失败"];
                }
            }];
        }];
        
    }];
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ItemModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (!CGSizeEqualToSize(model.imageSize, CGSizeZero)) {
        CGFloat w = (self.view.frame.size.width-20)/2.0;
        CGFloat h = model.imageSize.height/model.imageSize.width*w;
        return CGSizeMake(w, h);
    }
    return CGSizeMake(150, 150);
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        NSArray *imgArray = @[
                              @"http://img.ugirls.com/uploads/magazine/content/aee3f9eb0d5f003d607cc8130875a393_magazine_web_m.jpg",
                              @"http://img.ugirls.com/uploads/magazine/content/992afb4136cc5833c9b6c65c1505970b_magazine_web_m.jpg",
                              @"http://h.hiphotos.baidu.com/image/pic/item/4ec2d5628535e5dd2820232370c6a7efce1b623a.jpg",
                              @"http://c.hiphotos.baidu.com/image/pic/item/58ee3d6d55fbb2fb3943da344a4a20a44623dca8.jpg",
                              @"http://h.hiphotos.baidu.com/image/pic/item/cefc1e178a82b9010d834115768da9773912efee.jpg",
                              @"http://g.hiphotos.baidu.com/image/pic/item/9d82d158ccbf6c81166d0906b83eb13532fa4081.jpg",
                              @"http://d.hiphotos.baidu.com/image/pic/item/83025aafa40f4bfba09238b8074f78f0f636189f.jpg",
                              @"http://a.hiphotos.baidu.com/image/pic/item/43a7d933c895d1438d0b16fc77f082025baf07eb.jpg",
                              @"http://a.hiphotos.baidu.com/image/pic/item/6a600c338744ebf89a7496e0ddf9d72a6159a7ec.jpg",
                              @"http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc45a6646dd3cdbb6fd52663316.jpg",
                              @"http://b.hiphotos.baidu.com/image/pic/item/faedab64034f78f0dee066337d310a55b2191c02.jpg",
                              @"http://f.hiphotos.baidu.com/image/pic/item/c75c10385343fbf21f202205b57eca8065388f8c.jpg",
                              @"http://a.hiphotos.baidu.com/image/pic/item/023b5bb5c9ea15ce5ecc3e3db3003af33a87b2e0.jpg",
                              @"http://c.hiphotos.baidu.com/image/h%3D360/sign=93c0e40e6509c93d18f208f1af3cf8bb/aa64034f78f0f736f514e2010855b319eac413c3.jpg",
                              @"http://c.hiphotos.baidu.com/image/h%3D360/sign=4b4359a4d343ad4bb92e40c6b2035a89/03087bf40ad162d960a3c61d13dfa9ec8a13cd66.jpg",
                              @"http://e.hiphotos.baidu.com/image/pic/item/18d8bc3eb13533fa8e29072eaad3fd1f41345b16.jpg",
                              @"http://e.hiphotos.baidu.com/image/pic/item/5366d0160924ab1823b1f24c30fae6cd7b890b21.jpg",
                              @"http://d.hiphotos.baidu.com/image/pic/item/9d82d158ccbf6c814325fa12b83eb13533fa403e.jpg",
                              @"http://b.hiphotos.baidu.com/image/pic/item/50da81cb39dbb6fd5b7e1d000c24ab18972b37ea.jpg",
                              @"http://e.hiphotos.baidu.com/image/pic/item/d1a20cf431adcbeffaf5ae0faeaf2edda2cc9ff2.jpg",
                              @"http://f.hiphotos.baidu.com/image/pic/item/8326cffc1e178a82a470a9a9f403738da977e86f.jpg",
                              @"http://c.hiphotos.baidu.com/image/pic/item/f3d3572c11dfa9ec18cff61b60d0f703908fc1dd.jpg",
                              @"http://a.hiphotos.baidu.com/image/pic/item/fcfaaf51f3deb48f84e81cdef21f3a292df57828.jpg",
                              @"http://c.hiphotos.baidu.com/image/pic/item/faedab64034f78f0b53e1dfb7b310a55b3191c84.jpg",
                              @"http://d.hiphotos.baidu.com/image/pic/item/2e2eb9389b504fc2065e2bd2e1dde71191ef6de0.jpg",
                              @"http://c.hiphotos.baidu.com/image/pic/item/1f178a82b9014a90a47fdd6aad773912b21beea0.jpg",
                              @"http://b.hiphotos.baidu.com/image/pic/item/58ee3d6d55fbb2fb62237cfc4b4a20a44723dcd7.jpg",
                              @"http://c.hiphotos.baidu.com/image/pic/item/8b82b9014a90f603a136876a3c12b31bb051ed1d.jpg",
                              @"http://h.hiphotos.baidu.com/image/pic/item/9f2f070828381f302694f1a8ab014c086e06f026.jpg",
                              @"http://e.hiphotos.baidu.com/image/pic/item/3801213fb80e7bec30cd2f022d2eb9389b506b39.jpg",
                              @"http://e.hiphotos.baidu.com/image/pic/item/b7fd5266d016092477539711d60735fae6cd3441.jpg",
                              @"http://b.hiphotos.baidu.com/image/pic/item/e7cd7b899e510fb3269bfa61dc33c895d0430c41.jpg",
                              @"http://a.hiphotos.baidu.com/image/pic/item/d6ca7bcb0a46f21f46af2152f4246b600c33ae1c.jpg",
                              @"http://h.hiphotos.baidu.com/image/pic/item/b7003af33a87e95042d6236512385343faf2b4f2.jpg",
                              @"http://h.hiphotos.baidu.com/image/pic/item/55e736d12f2eb938d4997f3ad1628535e4dd6f05.jpg",
                              @"http://c.hiphotos.baidu.com/image/pic/item/95eef01f3a292df5821aa8f3b8315c6035a8737e.jpg",
                              @"http://g.hiphotos.baidu.com/image/pic/item/4b90f603738da977c75eb5bab351f8198618e32a.jpg",
                              @"http://g.hiphotos.baidu.com/image/pic/item/bd3eb13533fa828b38f1a605f91f4134960a5a01.jpg",
                              @"http://g.hiphotos.baidu.com/image/pic/item/960a304e251f95cadf7f016acd177f3e66095267.jpg",
                              @"http://g.hiphotos.baidu.com/image/pic/item/203fb80e7bec54e7e02e89c2bd389b504ec26a28.jpg"
                              ];
        
        for (NSString *item in imgArray) {
            ItemModel *model = [ItemModel new];
            model.imageUrl = item;
            
            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}

- (void)showText:(NSString *)text {
    
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        self.hud.mode = MBProgressHUDModeText;
        [self.view addSubview:self.hud];
    }
    self.hud.labelText = text;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:0.8];
    
}

@end
