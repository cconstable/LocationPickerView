//
//  UIImage+Icons.m
//
//  Created by Christopher Constable on 5/10/13.
//  Copyright (c) 2013 Futura IO. All rights reserved.
//

#import "UIImage+Icons.h"

@implementation UIImage (Icons)

+ (UIImage *)imageForXIcon
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *strokeColor = [UIColor blackColor];
    UIColor *shadowColor = [UIColor blackColor];
    CGSize shadowOffset = CGSizeMake(1.0, 2.0);
    CGFloat shadowBlurRadius = 3.0;
    
    // Line 1
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(5, 5)];
    [bezierPath addLineToPoint:CGPointMake(20, 20)];
    bezierPath.miterLimit = 11;
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadowColor.CGColor);
    [strokeColor setStroke];
    bezierPath.lineWidth = 5.0;
    [bezierPath stroke];
    CGContextRestoreGState(context);
    
    // Line 2
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(5, 20)];
    [bezierPath addLineToPoint:CGPointMake(20, 5)];
    bezierPath.miterLimit = 11;
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadowColor.CGColor);
    [strokeColor setStroke];
    bezierPath.lineWidth = 5.0;
    [bezierPath stroke];
    CGContextRestoreGState(context);
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

@end
