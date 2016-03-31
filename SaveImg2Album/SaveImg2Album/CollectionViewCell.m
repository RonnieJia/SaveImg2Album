//
//  CollectionViewCell.m
//  SaveImg2Album
//
//  Created by 辉贾 on 16/3/30.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor whiteColor];
    }
    return _imageView;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
@end
