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

-(IBAction)cutOut:(id)sender;

@end

@implementation CutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.drawingView.userInteractionEnabled = YES;
    self.cutOutBtn.enabled = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Cut Image

- (IBAction)cutOut:(id)sender
{
    //Save cut out image and its thumbnail
    [[ImagePieceReadWrite sharedClient] saveImageAndThumbnail:[self createPieceImage].CGImage];
}

-(UIImage *)createPieceImage
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
