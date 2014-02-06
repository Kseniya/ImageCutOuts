//
//  ShareView.h
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 2/5/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareKit/SHK.h>

@interface ShareView : UIView

@property (nonatomic, strong) SHKItem *item;
@property (strong) NSMutableArray *tableData;
@property (strong) NSMutableArray *exclusions;

+ (id)shareViewInView:(UIView*)view;

@end
