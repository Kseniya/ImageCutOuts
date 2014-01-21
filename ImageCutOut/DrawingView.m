//
//  DrawingView.m
//  FreehandDrawingTut
//
//  Created by Kseniya Kalyuk Zito on 1/8/14.
//
//

#import "DrawingView.h"

@implementation DrawingView
{
    CGPoint points[5];
    CGPoint startingPoint;
    uint count;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.path = [UIBezierPath bezierPath];
        [self.path setLineWidth:2.0];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.path = [UIBezierPath bezierPath];
        [self.path setLineWidth:2.0];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] setStroke];
    [[UIColor clearColor] setFill];
    [self.path stroke];
    [self.path fill];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.path removeAllPoints];
    count = 0;
    UITouch *touch = [touches anyObject];
    points[0] = [touch locationInView:self];
    [self.path moveToPoint:points[0]];
    startingPoint = points[0];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    count++;
    points[count] = p;
    
    //Adding curves to create smoother line
    if (count == 4)
    {
        //Move point 3 to the middle between points 2 and 4 to avoid sharp edges between curves. This way we create continuous curves
        points[3] = CGPointMake((points[2].x + points[4].x)/2.0, (points[2].y + points[4].y)/2.0);
        [self.path addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]];
        
        [self setNeedsDisplay];
        
        points[0] = points[3];
        points[1] = points[4];
        count = 1;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.path addLineToPoint:startingPoint];
    [self setNeedsDisplay];
    count = 0;
    startingPoint = CGPointZero;
}


@end
