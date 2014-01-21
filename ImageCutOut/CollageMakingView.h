//
//  CollageMakingView.h
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollageMakingView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;

-(void)addPiece:(UIImage*)image;

@end
