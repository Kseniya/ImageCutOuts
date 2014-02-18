//
//  UIScrollView+ZoomableImage.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 2/6/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "UIScrollView+ZoomableImage.h"
#import <objc/runtime.h>

NSString * const kZoomableImageViewKey = @"kZoomableImageView";

@implementation UIScrollView (ZoomableImage)
@dynamic imageView;

+ (UIScrollView*)zoomableWithImage:(UIImage*)image frame:(CGRect)frame
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    
    scrollView.imageView = [[UIImageView alloc]init];
    scrollView.imageView.image = image;
    scrollView.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size = image.size};
    [scrollView addSubview:scrollView.imageView];
    
    [scrollView centerScrollViewContents];
    [scrollView enableZoom];
    
    return scrollView;
}

-(void)setImageView:(UIImageView *)imageView
{
    objc_setAssociatedObject(self, &kZoomableImageViewKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIImageView*)imageView
{
    return objc_getAssociatedObject(self, &kZoomableImageViewKey);
}


- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}


-(void)enableZoom
{
    self.contentSize = self.imageView.image.size;
    
    CGRect scrollViewFrame = self.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.contentSize.height;
    CGFloat minScale = MAX(scaleWidth, scaleHeight);
    
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = 1.0f;
    
    self.scrollEnabled = YES;
}

-(void)disableZoom
{
    self.scrollEnabled = NO;
    self.maximumZoomScale = 1.0;
    self.minimumZoomScale = 1.0;
}

@end
