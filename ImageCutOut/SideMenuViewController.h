//
//  SideMenuViewController.h
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuViewController : UIViewController

typedef NS_ENUM(NSInteger, MenuAnimationType) {
    MenuAnimationTypeOpened,
    MenuAnimationTypeClosed
};

@property (nonatomic) IBOutlet UIViewController *mainViewController;
@property (nonatomic) IBOutlet UIViewController *menuViewController;

@property (assign, nonatomic) BOOL menuOpened;

- (void)openCloseMenuWithCompletion:(void (^)(MenuAnimationType animationType))completion;

@end


@interface UIViewController (SideMenuViewController)

@property (nonatomic, weak) SideMenuViewController *sideMenuViewController;

@end
