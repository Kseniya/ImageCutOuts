//
//  ViewController.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/8/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//
//  Cutting out pieces of the image and saving them in the documents directory.

#import "CutViewController.h"
#import "DrawingView.h"
#import "ImagePieceReadWrite.h"

@interface CutViewController ()

@property (nonatomic) IBOutlet UIImageView *imageViewToCut;
@property (nonatomic) IBOutlet DrawingView *drawingView;
@property (nonatomic) IBOutlet UIBarButtonItem *cutOutBtn;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

- (IBAction)cut:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)showImagePickerForPhotoPicker:(id)sender;

@end

@implementation CutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageViewToCut.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    
    //Enable touch on drawingView and enable cut button
    self.imageViewToCut.hidden = NO;
    self.drawingView.userInteractionEnabled = YES;
    self.cutOutBtn.enabled = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Button Actuons

- (IBAction)cut:(id)sender
{
    //Save cut out image and its thumbnail
    [self cutAndSaveImagePiece];
}


- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Cut Image Piece

- (void)cutAndSaveImagePiece
{
    [[ImagePieceReadWrite sharedClient] saveImageAndThumbnail:[self createPieceImage].CGImage completion:^(BOOL success) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)
            {
                UIAlertView *doneAlert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:@"Saved cutted piece"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [doneAlert show];
            }
            else
            {
                UIAlertView *doneAlert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:@"Failed saving cutted piece"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [doneAlert show];
            }
        });
    }];
}

- (UIImage *)createPieceImage
{
    float scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(self.imageViewToCut.bounds.size, NO, scale);
    
    UIBezierPath *path = self.drawingView.path;
    [path addClip];
    
    [self.imageViewToCut.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //create masked image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], CGRectMake(self.drawingView.path.bounds.origin.x* scale, self.drawingView.path.bounds.origin.y * scale, self.drawingView.path.bounds.size.width *scale, self.drawingView.path.bounds.size.height *scale));
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return image;
}

@end
