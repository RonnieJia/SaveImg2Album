//
//  ALAssetsLibrary+RJSavePhotoAlubm.m
//  SaveImg2Album
//
//  Created by 辉贾 on 16/3/30.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "ALAssetsLibrary+RJSavePhotoAlubm.h"

@implementation ALAssetsLibrary (RJSavePhotoAlubm)
- (void)saveImg:(UIImage *)image toAlbum:(NSString *)albumName withCompletionBlock:(DiySaveImgCompletion)completionBlock {
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error != nil) {
            completionBlock(nil, error);
            return;
        }
        SaveImgCompletion innerConpletion = ^(NSError *error) {
            if (NULL != completionBlock) {
                completionBlock(assetURL, error);
            }
        };
        
        [self addAssetURL:assetURL toAlbum:albumName withCompletionBlock:innerConpletion];
    }];
}

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName withCompletionBlock:(SaveImgCompletion)completionBlock {
    __block BOOL albumWasFound = NO;
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            albumWasFound = YES;
            
            [self assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                [group addAsset:asset];
                completionBlock(nil);
            } failureBlock:completionBlock];
            
            return;
        }
        
        if (group == nil && albumWasFound == NO) {
            __weak ALAssetsLibrary *weakSelf = self;
            
            [self addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                [weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    [group addAsset:asset];
                    completionBlock(nil);
                } failureBlock:completionBlock];
            } failureBlock:completionBlock];
        }
    } failureBlock:completionBlock];
}
@end
