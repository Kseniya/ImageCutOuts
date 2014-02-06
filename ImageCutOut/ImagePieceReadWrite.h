//
//  ImagePieceReadWrite.h
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePieceReadWrite : NSObject

@property (nonatomic, strong) NSArray *thumbnailsNames;
@property (nonatomic, strong) NSArray *imagesNames;

+ (instancetype)sharedClient;

- (void)saveImageAndThumbnail:(CGImageRef)imageRef completion:(void (^)(BOOL success))completion;
- (void)deleteImageAndThumbnailAtIndex:(NSInteger)index completion:(void (^)(BOOL success))completion;


- (UIImage*)thumbnailAtIndex:(NSInteger)index;
- (UIImage*)imageAtIndex:(NSInteger)index;



@end
