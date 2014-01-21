//
//  CollageMakingView.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "CollageMakingView.h"
#import "CollagePiece.h"

@interface CollageMakingView ()

@property (nonatomic, strong) NSMutableArray* piecesArray;
@property (nonatomic, strong) CollagePiece *selectedPiece;

@property (nonatomic, assign) CGFloat lastRotation;
@property (nonatomic, assign) CGFloat lastScale;

@end

@implementation CollageMakingView


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.backgroundImageView];
        [self addGestureRecognizers];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc]initWithFrame:self.frame];
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.backgroundImageView];
        [self addGestureRecognizers];
    }
    return self;
}


-(void)addGestureRecognizers
{
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
	pinchRecognizer.delaysTouchesEnded = NO;
	pinchRecognizer.cancelsTouchesInView = NO;
	[pinchRecognizer setDelegate:self];
	[self addGestureRecognizer:pinchRecognizer];
	
	UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
	rotationRecognizer.delaysTouchesEnded = NO;
	rotationRecognizer.cancelsTouchesInView = NO;
	[rotationRecognizer setDelegate:self];
	[self addGestureRecognizer:rotationRecognizer];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
	panRecognizer.delaysTouchesEnded = NO;
	panRecognizer.cancelsTouchesInView = NO;
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[self addGestureRecognizer:panRecognizer];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
	tapRecognizer.delaysTouchesEnded = NO;
	tapRecognizer.cancelsTouchesInView = NO;
	[tapRecognizer setNumberOfTapsRequired:1];
	[tapRecognizer setDelegate:self];
	[self addGestureRecognizer:tapRecognizer];
}


-(void)addPiece:(UIImage *)image
{
    if (!self.piecesArray)
    {
        self.piecesArray = [[NSMutableArray alloc]init];
    }
    
    CollagePiece *newPiece = [[CollagePiece alloc]initWithImage:image];
    newPiece.bounds = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    newPiece.center = self.backgroundImageView.center;
    
    [self addSubview:newPiece];
    [self.piecesArray addObject:newPiece];
}

#pragma mark Gestures

- (void)move:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            //Select piece that have been touched, bring to front and start moving
            CGPoint touchPoint = [recognizer locationInView:self];
            self.selectedPiece = [self pieceAtLocation:touchPoint];
            [self bringSubviewToFront:self.selectedPiece];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (self.selectedPiece) {
                CGPoint touchPoint = [recognizer locationInView:self];
                self.selectedPiece.center = CGPointMake(touchPoint.x, touchPoint.y);
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            break;
        }
        default:
        {
            //ignore
        }
    }
}


- (void)scale:(UIPinchGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            //Select piece that have been touched, bring to front and start scaling
            CGPoint touchPoint = [recognizer locationInView:self];
            self.selectedPiece = [self pieceAtLocation:touchPoint];
            [self bringSubviewToFront:self.selectedPiece];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (self.selectedPiece) {
                
                CGFloat scale = 1.0 - (self.lastScale - recognizer.scale);
                
                CGAffineTransform currentTransform = self.selectedPiece.transform;
                CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
                
                [self.selectedPiece setTransform:newTransform];
                
                self.lastScale = recognizer.scale;
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            self.lastScale = 1.0;
            
            break;
        }
        default:
        {
            //ignore
        }
    }
}


- (void)rotate:(UIRotationGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            //Select piece that have been touched, bring to front and start rotating
            CGPoint touchPoint = [recognizer locationInView:self];
            self.selectedPiece = [self pieceAtLocation:touchPoint];
            [self bringSubviewToFront:self.selectedPiece];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (self.selectedPiece) {
                CGFloat rotation = recognizer.rotation - self.lastRotation;
                
                CGAffineTransform currentTransform = self.selectedPiece.transform;
                CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
                
                [self.selectedPiece setTransform:newTransform];
                
                self.lastRotation = recognizer.rotation;
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            self.lastRotation = 0.0;
            
            break;
        }
        default:
        {
            //ignore
        }
    }
}


- (void)tapped:(UITapGestureRecognizer *)recognizer
{
    //Bring to front piece that have been tapped
    CGPoint touchPoint = [recognizer locationInView:self];
    self.selectedPiece = [self pieceAtLocation:touchPoint];
    [self bringSubviewToFront:self.selectedPiece];
}


- (CollagePiece*)pieceAtLocation:(CGPoint)point {
    
    UIView* view = nil;
    for (UIView *subview in self.subviews)
    {
        if (CGRectContainsPoint(subview.frame, point)) {
            if ([subview isKindOfClass:[CollagePiece class]])
            {
                view = subview;
                break;
            }
        }
    }
    
    return (CollagePiece*)view;
}


@end
