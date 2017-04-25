//
//  TYDDrawView.m
//  DroiKids
//
//  Created by superjunjun on 15/8/22.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDDrawView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TYDDrawView 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.arrayStrokes = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.arrayStrokes = [NSMutableArray array];
    }
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1.0, 0.0, 0.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);

    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    if (self.arrayStrokes)
    {
        int arraynum = 0;
        // each iteration draw a stroke
        // line segments within a single stroke (path) has the same color and line width
        for (NSDictionary *dictStroke in self.arrayStrokes)
        {
            NSArray *arrayPointsInstroke = [dictStroke objectForKey:@"points"];
            UIColor *color = [dictStroke objectForKey:@"color"];
            float size = [[dictStroke objectForKey:@"size"] floatValue];
            [color set];        // equivalent to both setFill and setStroke
            // draw the stroke, line by line, with rounded joints
            UIBezierPath* pathLines = [UIBezierPath bezierPath];
            CGPoint pointStart = CGPointFromString([arrayPointsInstroke objectAtIndex:0]);
            [pathLines moveToPoint:pointStart];
            for (int i = 0; i < (arrayPointsInstroke.count - 1); i++)
            {
                CGPoint pointNext = CGPointFromString([arrayPointsInstroke objectAtIndex:i+1]);
                [pathLines addLineToPoint:pointNext];
            }
            pathLines.lineWidth = size;
            pathLines.lineJoinStyle = kCGLineJoinRound;
            pathLines.lineCapStyle = kCGLineCapRound;
            [pathLines stroke];
            
            arraynum++;
        }
    }
    
}

// Start new dictionary for each touch, with points and color
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    NSMutableArray *arrayPointsInStroke = [NSMutableArray array];
    NSMutableDictionary *dictStroke = [NSMutableDictionary dictionary];
    [dictStroke setObject:arrayPointsInStroke forKey:@"points"];
    [dictStroke setObject:[UIColor redColor] forKey:@"color"];
    [dictStroke setObject:[NSNumber numberWithFloat:5] forKey:@"size"];
    
    CGPoint point = [[touches anyObject] locationInView:self];
    _firstPoint = point;
    [arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
    
    [self.arrayStrokes addObject:dictStroke];
}

// Add each point to points array
- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self];
    NSMutableArray *arrayPointsInStroke = [[self.arrayStrokes lastObject] objectForKey:@"points"];
    [arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
    
    CGRect rectToRedraw = CGRectMake(\
                                     ((prevPoint.x>point.x)?point.x:prevPoint.x)-5,\
                                     ((prevPoint.y>point.y)?point.y:prevPoint.y)-5,\
                                     fabs(point.x-prevPoint.x)+2*5,\
                                     fabs(point.y-prevPoint.y)+2*5\
                                     );
    [self setNeedsDisplayInRect:rectToRedraw];
}

// Send over new trace when the touch ends
- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
    CGPoint lastPoint = [[touches anyObject] locationInView:self];
    NSMutableArray *arrayPointsInStroke = [[self.arrayStrokes lastObject] objectForKey:@"points"];
    [arrayPointsInStroke addObject:NSStringFromCGPoint(lastPoint)];
    [arrayPointsInStroke addObject:NSStringFromCGPoint(_firstPoint)];

    CGRect rectToRedraw = CGRectMake(\
                                     ((lastPoint.x>_firstPoint.x)?_firstPoint.x:lastPoint.x)-5,\
                                     ((lastPoint.y>_firstPoint.y)?_firstPoint.y:lastPoint.y)-5,\
                                     fabs(_firstPoint.x-lastPoint.x)+2*5,\
                                     fabs(_firstPoint.y-lastPoint.y)+2*5\
                                     );
    [self setNeedsDisplayInRect:rectToRedraw];
    
    if(self.draweDlegate && [self.draweDlegate respondsToSelector:@selector(drawEnd)])
    {
        [self.draweDlegate drawEnd];
    }
}

- (void)clearCanvas
{
    [self.arrayStrokes removeAllObjects];
    [self setNeedsDisplay];
}
@end
