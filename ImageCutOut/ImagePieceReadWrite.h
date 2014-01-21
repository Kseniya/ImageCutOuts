//
//  ImagePieceReadWrite.h
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePieceReadWrite : NSObject

+ (instancetype)sharedClient;
- (void)saveImageAndThumbnail:(CGImageRef)imageRef;

- (NSArray*)thumbnailsNames;

- (UIImage*)thumbnailAtIndex:(NSInteger)index;
- (UIImage*)imageAtIndex:(NSInteger)index;

@end
