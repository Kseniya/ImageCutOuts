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

@interface CollageViewController ()

@property (nonatomic) IBOutlet CollageMakingView *collageMakingView;
@property (nonatomic) IBOutlet UIBarButtonItem *menuBtn;
@property (nonatomic) IBOutlet UIBarButtonItem *saveBtn;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;


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


#pragma mark UIImagePicker

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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.collageMakingView.backgroundImageView.image = [info valueForKey:UIImagePickerControllerOriginalImage];
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


- (IBAction)menuButtonPressed:(id)sender
{
    [self.sideMenuViewController menuButtonPressed:sender];
    
    //Update Menu
    if ([self.sideMenuViewController.menuViewController isKindOfClass:[MenuViewController class]])
    {
        MenuViewController *menuViewController = (MenuViewController *)self.sideMenuViewController.menuViewController;
        [menuViewController updateMenu];
    }
}

- (void)addPieceToCollage:(UIImage *)image
{
    [self.collageMakingView addPiece:image];
}


- (IBAction)save:(id)sender
{
    //save final image to camera roll
    UIImageWriteToSavedPhotosAlbum([self finalCollage], nil, nil, nil);
}


- (UIImage*)finalCollage
{
    float scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(self.collageMakingView.bounds.size, NO, scale);
    
    [self.collageMakingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //create image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
