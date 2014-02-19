//
//  CollageViewController.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "CollageViewController.h"
#import "SideMenuViewController.h"
#import "PiecesViewController.h"
#import <ShareKit.h>
#import <ShareKit/SHKShareMenu.h>
#import "ShareView.h"


@interface CollageViewController ()

@property (nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)menuButtonPressed:(id)sender;
- (IBAction)save:(id)sender;

@end

@implementation CollageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)addPieceToCollage:(UIImage *)image
{
    [self.collageMakingView addPieceWithImage:image];
}

-(void)setBackgroundImageViewWithImage:(UIImage*)image
{
    [self.collageMakingView setBackgroundImageViewWithImage:image];
}

//Closing side menu
-(void)handleSwipeGesture:(UISwipeGestureRecognizer*)recognizer
{
    if (self.sideMenuViewController.menuOpened)
    {
        [self.sideMenuViewController openCloseMenuWithCompletion:^(MenuAnimationType animationType) {
            NSLog(@"Closed");
            self.collageMakingView.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark Button Actions

- (IBAction)menuButtonPressed:(id)sender
{
    [self.sideMenuViewController openCloseMenuWithCompletion:^(MenuAnimationType animationType) {
        if (animationType == MenuAnimationTypeOpened)
        {
            NSLog(@"OPENED");
            self.collageMakingView.userInteractionEnabled = NO;
        }
        else
        {
            NSLog(@"Closed");
            self.collageMakingView.userInteractionEnabled = YES;
        }
    }];
    
    //Update Menu
    if ([self.sideMenuViewController.menuViewController isKindOfClass:[PiecesViewController class]])
    {
        PiecesViewController *piecesViewController = (PiecesViewController *)self.sideMenuViewController.menuViewController;
        [piecesViewController updateMenu];
    }
}

- (IBAction)save:(id)sender
{
    // Create the item to share
    SHKItem *item = [SHKItem image:[self.collageMakingView finalCollage] title:@"blablabla"];
    //Show share view with options
    ShareView *view = [ShareView shareViewInView:self.view];
    view.item = item;
}


- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        
        UIAlertView *doneAlert = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"Sorry, there was an error while saving your image"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [doneAlert show];
        
    } else {
        
        UIAlertView *doneAlert = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"YAAY!! Image have been saved to camera roll"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [doneAlert show];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


