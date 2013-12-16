//
//  ASAsteroid.m
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/13/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import "ASCAAsteroid.h"

#define MAX_CORNERS 8

@implementation ASCAAsteroid

- (id)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    
    return self;
}

- (NSArray *)chooseRandomNumbersFromPointsArray:(NSArray *)array
{
    NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:self.corners];
    for (int i=0; i<MAX_CORNERS; i++)
        [indexes addObject:[NSNumber numberWithInt:i]];
    
    NSMutableArray *shuffle = [[NSMutableArray alloc] initWithCapacity:self.corners];
    
    for (int i = 0; i < self.corners; i++) {
        
        int index = arc4random() % [indexes count];
        [shuffle addObject:[indexes objectAtIndex:index]];
        [indexes removeObjectAtIndex:index];
    }
    
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [shuffle sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    return shuffle;
}


- (void)drawInContext:(CGContextRef)theContext
{
    [super drawInContext:theContext];
    
    float widthAst = self.bounds.size.width;
    float heightAst = self.bounds.size.height;
    //points to create 8 polygons
    NSValue *vaue = [NSValue valueWithCGPoint:CGPointMake(widthAst/2+0, widthAst/2+heightAst/2)];
    NSValue *vaue1 = [NSValue valueWithCGPoint:CGPointMake(widthAst/2+widthAst/2-widthAst/8, heightAst/2+heightAst/2-widthAst/8)];
    NSValue *vaue2 = [NSValue valueWithCGPoint:CGPointMake(widthAst/2+widthAst/2, heightAst/2+0)];
    NSValue *vaue3 = [NSValue valueWithCGPoint:CGPointMake(widthAst/2+widthAst/2-widthAst/8, -(heightAst/2-heightAst/8)+widthAst/2)];
    NSValue *vaue4 = [NSValue valueWithCGPoint:CGPointMake(widthAst/2+0, -heightAst/2+heightAst/2)];
    NSValue *vaue5 = [NSValue valueWithCGPoint:CGPointMake(-(widthAst/2-widthAst/8)+widthAst/2, -(heightAst/2-heightAst/8)+heightAst/2)];
    NSValue *vaue6 = [NSValue valueWithCGPoint:CGPointMake(-widthAst/2+widthAst/2, 0+heightAst/2)];
    NSValue *vaue7 = [NSValue valueWithCGPoint:CGPointMake(-(widthAst/2-widthAst/8)+widthAst/2, heightAst/2+heightAst/2-heightAst/8)];
    NSValue *vaue8 = [NSValue valueWithCGPoint:CGPointMake(widthAst/2+0, heightAst/2+heightAst/2)];
    
    
    NSArray *arr = [NSArray arrayWithObjects:vaue, vaue1, vaue2, vaue3, vaue4, vaue5, vaue6, vaue7, vaue8, nil];

    CGPoint points[8] = {};
    
// choose random sorted clockWise Points to create random corners asteroid
    NSArray *sorted = [self chooseRandomNumbersFromPointsArray:arr];
    
    for (int i = 0; i < sorted.count; i++) {
        
        points[i] = [arr[[sorted[i] integerValue]] CGPointValue];
    }
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    
    CGPathAddLines(thePath, NULL, points, self.corners);
    
    CGPathCloseSubpath(thePath);
    
    CGContextBeginPath(theContext);
    CGContextAddPath(theContext, thePath );
    
    CGContextSetFillColorWithColor(theContext, [UIColor redColor].CGColor);
    CGContextFillPath(theContext);
    CFRelease(thePath);
    
}


@end
