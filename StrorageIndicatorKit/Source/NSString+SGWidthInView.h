//
//  NSString+SGWidthInView.h
//  StrorageIndicatorKit
//
//  Created by Simon Gaus on 09.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

@import Cocoa;

/**
 
 Convenient categorie to calculate the width of a string if drawn in the given site.
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SGWidthInView)
#pragma mark - Calculating the width
///----------------------------------------------------
/// @name Calculating the width
///----------------------------------------------------

/**
 @brief Returns the width of the string if drawen in an NSTextField with the given font.
 @warning Whether the string fits inside a NStextField with the given width also depends on the settings of the text field. Setting line break to truncate tail will lead to a truncated tail while clipping works for me.
 @return The width of the string.
 */
- (CGFloat)widthWithPoints:(CGFloat)points;


@end

NS_ASSUME_NONNULL_END
