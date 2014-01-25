//
//  SideMenuViewController.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "SideMenuViewController.h"
#import <objc/runtime.h>

#define OPEN_DURATION 0.25f
#define OPEN_OFFSET 260.0f

@interface SideMenuViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *menuView;


@end

@implementation SideMenuViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.menuOpened = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add Shadow to mainView
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.mainView.bounds];
    self.mainView.opaque = YES;
    self.mainView.backgroundColor = [UIColor whiteColor];
	self.mainView.layer.masksToBounds = NO;
	self.mainView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.mainView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.mainView.layer.shadowOpacity = 1.0f;
	self.mainView.layer.shadowRadius = 2.5f;
	self.mainView.layer.shadowPath = shadowPath.CGPath;
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.mainView addGestureRecognizer:swipeRecognizer];
    
    //starting position, menu closed
    self.menuOpened = NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"mainview_embed"]) {
        self.mainViewController = [segue destinationViewController];
        self.mainViewController.sideMenuViewController = self;
    }
    else if ([segueName isEqualToString: @"menuview_embed"]) {
        self.menuViewController = [segue destinationViewController];
        self.menuViewController.sideMenuViewController = self;
    }
}


- (void)openCloseMenuAnimated:(BOOL)animated completion:(void (^)(MenuAnimationType))completion
{
    [self animateMenuWithDuration:OPEN_DURATION completion:completion];
}

- (void)animateMenuWithDuration:(NSTimeInterval)animationDuration completion:(void (^)(MenuAnimationType))completion
{
    //if menu is closed, open it. If open, close
    if (!self.menuOpened)
    {
        [self openAnimationWithDuration:animationDuration completion:completion];
    }
    else if (self.menuOpened)
    {
        [self closeAnimationWithDuration:animationDuration completion:completion];
    }
}


- (void) openAnimationWithDuration:(NSTimeInterval)duration completion:(void (^)(MenuAnimationType))completion
{
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
     {
         self.mainView.frame = CGRectMake(OPEN_OFFSET, 0.0f, self.mainView.frame.size.width, self.mainView.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         self.menuOpened = YES;
         
         if (completion)
         {
             completion(MenuAnimationTypeOpened);
         }
     }];
}


- (void)closeAnimationWithDuration:(NSTimeInterval)duration completion:(void (^)(MenuAnimationType))completion
{
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
     {
         self.mainView.frame = CGRectMake(0.0f, 0.0f, self.mainView.frame.size.width, self.mainView.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         self.menuOpened = NO;
         
         if (completion)
         {
             completion(MenuAnimationTypeClosed);
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)handleSwipeGesture:(UIPanGestureRecognizer*)recognizer
{
    if (self.menuOpened)
    {
        [self closeAnimationWithDuration:OPEN_DURATION completion:^(MenuAnimationType animationType) {
            NSLog(@"Closed");
        }];
    }
}



@end



@implementation UIViewController (SideMenuViewController)

- (void)setSideMenuViewController:(SideMenuViewController *)sideMenuViewController
{
    objc_setAssociatedObject(self, @selector(sideMenuViewController), sideMenuViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (SideMenuViewController *)sideMenuViewController
{
    SideMenuViewController *sideMenuController = objc_getAssociatedObject(self, @selector(sideMenuViewController));
    if (!sideMenuController) {
        sideMenuController = self.parentViewController.sideMenuViewController;
    }
    return sideMenuController;
}

@end

