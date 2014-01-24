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

dispatch_queue_t readWriteQueue;

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

        readWriteQueue = dispatch_queue_create("readWriteQueue", NULL);
        dispatch_async(readWriteQueue, ^{
            
            NSString *thumbPath = [self thumbnailsDirectoryPath];
            NSString *imagesPath = [self imagesDirectoryPath];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:thumbPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:thumbPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create thumbnails folder
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create images folder
            
            [self updateArrays];
        });
    }
    return self;
}


# pragma mark Save New Piece Image

- (void)saveImageAndThumbnail:(CGImageRef)imageRef success:(void (^)(BOOL))success
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *dateMark = [dateFormatter stringFromDate:[NSDate date]];
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    UIImage *thumbnailImage = [self createThumbnailOfImage:image];
    
    NSString *imagePath = [[self imagesDirectoryPath] stringByAppendingFormat:@"/image_%@@2x.png", dateMark];
    NSString *thumbnailPath = [[self thumbnailsDirectoryPath] stringByAppendingFormat:@"/image_%@@2x.png", dateMark];
    
    __block BOOL savedTumbnail = NO;
    __block BOOL savedImage = NO;
    
    //save image and the thumbnail in "Images" and "Thumbnails" directories
    dispatch_async(readWriteQueue, ^{
        savedImage = [self saveImageFile:image atPath:imagePath];
        
        if (savedImage) //if image got saved save thumbnail
        {
            savedTumbnail = [self saveImageFile:thumbnailImage atPath:thumbnailPath];
            
            if (savedTumbnail) //if thumbnail got saved, return success true
            {
                success(savedImage);
                [self updateArrays];
            }
            else //if thumbnail didn't got saved, delete saved image, return success fail
            {
                success(savedTumbnail);
                [self deleteImageFileAtPath:imagePath];
            }
        }
        else //if image didn't got saved, return success fail
        {
            success (savedImage);
        }
    });
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


- (BOOL)saveImageFile:(UIImage*)pieceImage atPath:(NSString*)path
{
    //save image
    return [UIImagePNGRepresentation(pieceImage) writeToFile:path atomically:YES];
}


#pragma mark Delete Piece Image

- (void)deleteImageAndThumbnailAtIndex:(NSInteger)index success:(void (^)(BOOL))success
{
    dispatch_async(readWriteQueue, ^{
        [self deleteImageFileAtPath:[self imagePathAtIndex:index]];
        [self deleteImageFileAtPath:[self thumbnailPathAtIndex:index]];
        [self updateArrays];
        
        success (YES);
    });
}


- (BOOL)deleteImageFileAtPath:(NSString*)path
{
    NSError *error;
    return [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}


- (void)updateArrays
{
    NSArray *tumbsOldToNew = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self thumbnailsDirectoryPath] error:nil];
    NSArray *imagesOldToNew = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self imagesDirectoryPath] error:nil];
    
    self.thumbnailsNames = [[tumbsOldToNew reverseObjectEnumerator] allObjects];
    self.imagesNames = [[imagesOldToNew reverseObjectEnumerator] allObjects];
    
    [self compareArrays];
}

-(void)compareArrays
{
    //Make sure all the images and thumbnails are matching
    if ([self.thumbnailsNames isEqualToArray:self.imagesNames])
    {
        NSLog(@"images and thumbnails lists are the SAME");
    }
    else
    {
        NSLog(@"images and thumbnails lists are DIFFERENT");
        //DO SOMETHING!!!
    }
}


- (UIImage*)thumbnailAtIndex:(NSInteger)index
{
    return [UIImage imageWithContentsOfFile:[self thumbnailPathAtIndex:index]];
}


- (UIImage*)imageAtIndex:(NSInteger)index
{
    return [UIImage imageWithContentsOfFile:[self imagePathAtIndex:index]];
}


- (NSString*)thumbnailPathAtIndex:(NSInteger)index
{
    if (index < self.thumbnailsNames.count)
    {
        return [[self thumbnailsDirectoryPath] stringByAppendingPathComponent:self.thumbnailsNames[index]];
    }
    return nil;
}


- (NSString*)imagePathAtIndex:(NSInteger)index
{
    if (index < self.imagesNames.count)
    {
        return [[self imagesDirectoryPath] stringByAppendingPathComponent:self.imagesNames[index]];
    }
    return nil;
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
