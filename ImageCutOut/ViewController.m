//
//  ViewController.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/8/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//
//  Cutting out pieces of the image and saving them in the documents directory.

#import "ViewController.h"
#import "DrawingShapeView.h"

@interface ViewController ()

@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet DrawingShapeView *pathView;

-(IBAction)cutOut:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(IBAction)cutOut:(id)sender
{
    float scale = [[UIScreen mainScreen] scale];

    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, scale);
    
    UIBezierPath *path = self.pathView.path;
    [path addClip];
    
    [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //create masked image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], CGRectMake(self.pathView.path.bounds.origin.x* scale, self.pathView.path.bounds.origin.y * scale, self.pathView.path.bounds.size.width *scale, self.pathView.path.bounds.size.height *scale));
    
    //create file path in documents directory
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
	NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"image_%@.png", [dateFormatter stringFromDate:[NSDate date]]];
    
    //save the file
    [UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]) writeToFile:destinationPath atomically:YES];
    CGImageRelease(imageRef);
}




@end
