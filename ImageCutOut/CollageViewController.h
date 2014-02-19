//
//  CollageViewController.h
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollageMakingView.h"

@interface CollageViewController : UIViewController 

@property (nonatomic) IBOutlet CollageMakingView *collageMakingView;

- (void) addPieceToCollage:(UIImage*)image;
- (void)setBackgroundImageViewWithImage:(UIImage*)image;

@end
