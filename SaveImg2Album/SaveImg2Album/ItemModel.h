//
//  ItemModel.h
//  SaveImg2Album
//
//  Created by 辉贾 on 16/3/30.
//  Copyright © 2016年 RJ. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ItemModel : NSObject
@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, assign) CGSize imageSize;
@end
