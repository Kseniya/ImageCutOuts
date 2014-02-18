//
//  UIScrollView+ZoomableImage.h
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 2/6/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (ZoomableImage)

@property (nonatomic, strong) UIImageView *imageView;

+ (UIScrollView*)zoomableWithImage:(UIImage*)image frame:(CGRect)frame;
- (void)centerScrollViewContents;
- (void)enableZoom;
- (void)disableZoom;

@end
