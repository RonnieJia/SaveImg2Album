//
//  ALAssetsLibrary+RJSavePhotoAlubm.h
//  SaveImg2Album
//
//  Created by 辉贾 on 16/3/30.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SaveImgCompletion)(NSError *error);
typedef void(^DiySaveImgCompletion)(NSURL *assetUrl, NSError *error);

@interface ALAssetsLibrary (RJSavePhotoAlubm)
- (void)saveImg:(UIImage *)image toAlbum:(NSString *)albumName withCompletionBlock:(DiySaveImgCompletion)completionBlock;
- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName withCompletionBlock:(SaveImgCompletion)completionBlock;
@end
