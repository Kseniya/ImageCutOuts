//
//  CollageViewController.h
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (void) addPieceToCollage:(UIImage*)image;

@end
