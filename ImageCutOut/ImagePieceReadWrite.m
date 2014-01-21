//
//  ImagePieceReadWrite.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "ImagePieceReadWrite.h"

#define THUMBNAIL_HEIGHT 100.0

static NSString * const kThumbnailsDirectory = @"Thumbnails";
static NSString * const kImagesDirectory = @"Images";

@implementation ImagePieceReadWrite

//Shared singleton
+ (instancetype)sharedClient {
    static ImagePieceReadWrite *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ImagePieceReadWrite alloc] init];
    });
    
    return _sharedClient;
}

-(id)init
{
    if (self = [super init]) {
        NSString *thumbPath = [self thumbnailsDirectoryPath];
        NSString *imagesPath = [self imagesDirectoryPath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:thumbPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:thumbPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create thumbnails folder
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create images folder
    }
    return self;
}

- (void)saveImageAndThumbnail:(CGImageRef)imageRef
{
    //create file paths with date mark
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagesDirectoryPath = [documentsDirectory stringByAppendingPathComponent:kImagesDirectory];
    NSString *thumbsDirectoryPath = [documentsDirectory stringByAppendingPathComponent:kThumbnailsDirectory];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    
    float scale = THUMBNAIL_HEIGHT/[UIImage imageWithCGImage:imageRef].size.height;
    NSLog(@"%f", scale);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    //save image and the thumbnail in "Images" and "Thumbnails" directories
    [self saveImage:[UIImage imageWithCGImage:imageRef scale:scale orientation:image.imageOrientation] atPath:[thumbsDirectoryPath stringByAppendingFormat:@"/image_%@@2x.png", [dateFormatter stringFromDate:[NSDate date]]]];
    [self saveImage:image atPath:[imagesDirectoryPath stringByAppendingFormat:@"/image_%@@2x.png", [dateFormatter stringFromDate:[NSDate date]]]];
    
}

- (void)saveImage:(UIImage*)pieceImage atPath:(NSString*)path
{
    //save image
    [UIImagePNGRepresentation(pieceImage) writeToFile:path atomically:YES];
}


-(UIImage*)createThumbnailOfImage:(UIImage*)image
{
    
    float scale = THUMBNAIL_HEIGHT/image.size.height;
    float width = image.size.width *scale;
    CGSize newSize = CGSizeMake(width, THUMBNAIL_HEIGHT);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSArray*)thumbnailsNames
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    return [fileManager contentsOfDirectoryAtPath:[self thumbnailsDirectoryPath] error:nil];
}

- (UIImage*)thumbnailAtIndex:(NSInteger)index
{
    NSString* path = [[self thumbnailsDirectoryPath] stringByAppendingPathComponent:self.thumbnailsNames[index]];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)imageAtIndex:(NSInteger)index
{
    NSString* path = [[self imagesDirectoryPath] stringByAppendingPathComponent:self.thumbnailsNames[index]];
    return [UIImage imageWithContentsOfFile:path];
}


#pragma mark Directories Paths

- (NSString*)thumbnailsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", kThumbnailsDirectory]];
}

- (NSString*)imagesDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", kImagesDirectory]];
}

@end
