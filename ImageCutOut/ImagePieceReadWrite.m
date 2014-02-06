//
//  ImagePieceReadWrite.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "ImagePieceReadWrite.h"

#define MAX_THUMBNAIL_HEIGHT 100.0
#define MAX_THUMBNAIL_WIDTH 200.0

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
        
        __block id weakSelf = self;
        
        dispatch_async(readWriteQueue, ^{ //NSFileManager and NSArray are thread safe
            
            NSString *thumbPath = [weakSelf thumbnailsDirectoryPath];
            NSString *imagesPath = [weakSelf imagesDirectoryPath];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:thumbPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:thumbPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create thumbnails folder
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create images folder
            
            [weakSelf updateArrays];
        });
    }
    return self;
}


# pragma mark Save New Piece Image

- (void)saveImageAndThumbnail:(CGImageRef)imageRef completion:(void (^)(BOOL))completion
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
    __block id weakSelf = self;
    
    //save image and the thumbnail in "Images" and "Thumbnails" directories
    dispatch_async(readWriteQueue, ^{
        savedImage = [weakSelf saveImageFile:image atPath:imagePath];
        
        if (savedImage) //if image got saved save thumbnail
        {
            savedTumbnail = [weakSelf saveImageFile:thumbnailImage atPath:thumbnailPath];
            
            if (savedTumbnail) //if thumbnail got saved, return success true
            {
                completion(savedImage);
                [weakSelf updateArrays];
            }
            else //if thumbnail didn't got saved, delete saved image, return success fail
            {
                completion(savedTumbnail);
                [weakSelf deleteImageFileAtPath:imagePath];
            }
        }
        else //if image didn't got saved, return success fail
        {
            completion(savedImage);
        }
    });
}


-(UIImage*)createThumbnailOfImage:(UIImage*)image
{
    float scale = 1.0;
    
    if (image.size.height > MAX_THUMBNAIL_HEIGHT)
    {
        scale = MAX_THUMBNAIL_HEIGHT/image.size.height;
    }
    if (image.size.width *scale > MAX_THUMBNAIL_WIDTH)
    {
        scale = MAX_THUMBNAIL_WIDTH/image.size.width;
    }
    float height = image.size.height *scale;
    float width = image.size.width *scale;
    
    CGSize newSize = CGSizeMake(width, height);
    
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

- (void)deleteImageAndThumbnailAtIndex:(NSInteger)index completion:(void (^)(BOOL))completion
{
    __block id weakSelf = self;
    
    dispatch_async(readWriteQueue, ^{
        [weakSelf deleteImageFileAtPath:[weakSelf imagePathAtIndex:index]];
        [weakSelf deleteImageFileAtPath:[weakSelf thumbnailPathAtIndex:index]];
        [weakSelf updateArrays];
        
        completion(YES);
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
