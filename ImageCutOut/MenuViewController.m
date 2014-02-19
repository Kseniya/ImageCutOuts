//
//  MenuViewController.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 2/18/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "MenuViewController.h"
#import "CollageViewController.h"
#import "SideMenuViewController.h"
#import "PiecesViewController.h"

@interface MenuViewController (ImagePickerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@interface MenuViewController ()

@property (nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (nonatomic) IBOutlet UIButton *selectPhotoBtn;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

- (IBAction)showImagePickerForPhotoPicker:(id)sender;
- (IBAction)showImagePickerForCamera:(id)sender;


@end

@implementation MenuViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation MenuViewController (ImagePickerDelegate)

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    SideMenuViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
    
    [self presentViewController:viewController animated:NO completion:^{
        
        CollageViewController *collageController = (CollageViewController*) viewController.mainViewController;
        [collageController setBackgroundImageViewWithImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
    }];
    
    self.imagePickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

