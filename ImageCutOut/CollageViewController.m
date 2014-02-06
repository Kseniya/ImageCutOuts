//
//  CollageViewController.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "CollageViewController.h"
#import "SideMenuViewController.h"
#import "CollageMakingView.h"
#import "MenuViewController.h"
#import <ShareKit.h>
#import <ShareKit/SHKShareMenu.h>
#import "ShareView.h"

@interface CollageViewController (ImagePickerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@interface CollageViewController ()

@property (nonatomic) IBOutlet CollageMakingView *collageMakingView;
@property (nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (nonatomic) IBOutlet UIButton *selectPhotoBtn;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;


- (IBAction)showImagePickerForPhotoPicker:(id)sender;
- (IBAction)showImagePickerForCamera:(id)sender;
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
    [self animateOpening];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)animateOpening
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    [animation setFromValue:[NSNumber numberWithFloat:-self.takePhotoBtn.frame.size.width/2]];
    [animation setToValue:[NSNumber numberWithFloat:self.takePhotoBtn.frame.size.width/2 - 20.0]];
    [animation setDuration:0.5];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.5 :1.4 :1 :1]];
    [self.takePhotoBtn.layer addAnimation:animation forKey:@"takeButtonMoveIn"];
    
    CABasicAnimation * selectBtnAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    [selectBtnAnimation setFromValue:[NSNumber numberWithFloat:self.view.frame.size.width + self.selectPhotoBtn.frame.size.width/2]];
    [selectBtnAnimation setToValue:[NSNumber numberWithFloat:self.view.frame.size.width - self.selectPhotoBtn.frame.size.width/2 + 20.0]];
    [selectBtnAnimation setDuration:0.5];
    [selectBtnAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.5 :1.4 :1 :1]];
    [self.selectPhotoBtn.layer addAnimation:selectBtnAnimation forKey:@"selectButtonMoveIn"];
}


- (void)addPieceToCollage:(UIImage *)image
{
    [self.collageMakingView addPieceWithImage:image];
}

#pragma mark UIImagePicker

- (IBAction)showImagePickerForCamera:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark Button Actions

- (IBAction)menuButtonPressed:(id)sender
{
    [self.sideMenuViewController openCloseMenuAnimated:YES completion:^(MenuAnimationType animationType) {
        if (animationType == MenuAnimationTypeOpened)
        {
            NSLog(@"OPENED");
        }
        else
        {
            NSLog(@"Closed");
        }
    }];
    
    //Update Menu
    if ([self.sideMenuViewController.menuViewController isKindOfClass:[MenuViewController class]])
    {
        MenuViewController *menuViewController = (MenuViewController *)self.sideMenuViewController.menuViewController;
        [menuViewController updateMenu];
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


@implementation CollageViewController (ImagePickerDelegate)

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.collageMakingView setBackgroundImageViewWithImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    
    //Enable touch on collageMakingViee and enable save and menu buttons.
    self.collageMakingView.userInteractionEnabled = YES;
    self.navigationBar.hidden = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
