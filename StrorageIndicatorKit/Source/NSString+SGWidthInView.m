//
//  NSString+SGWidthInView.m
//  StrorageIndicatorKit
//
//  Created by Simon Gaus on 09.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

#import "NSString+SGWidthInView.h"

#pragma mark - IMPLEMENTATION


@implementation NSString (SGWidthInView)
#pragma mark - Calculate size

- (CGSize)sizeWithFont:(NSFont *)font {
    NSRect textRect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font}];
    return textRect.size;
}

- (CGSize)sizeWithPoints:(CGFloat)points {
    NSFont *font = [NSFont systemFontOfSize:points];
    return [self sizeWithFont:font];
}

#pragma mark - Calculate width

- (CGFloat)widthWithPoints:(CGFloat)points {
    return [self sizeWithPoints:points].width;
}

#pragma mark -
@end
