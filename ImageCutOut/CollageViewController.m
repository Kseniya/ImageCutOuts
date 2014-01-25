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


@interface CollageViewController (ImagePickerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@interface CollageViewController ()

@property (nonatomic) IBOutlet CollageMakingView *collageMakingView;
@property (nonatomic) IBOutlet UIBarButtonItem *menuBtn;
@property (nonatomic) IBOutlet UIBarButtonItem *saveBtn;

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
    //save final image to camera roll
    UIImageWriteToSavedPhotosAlbum([self.collageMakingView finalCollage], self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
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
    self.saveBtn.enabled = YES;
    self.menuBtn.enabled = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
