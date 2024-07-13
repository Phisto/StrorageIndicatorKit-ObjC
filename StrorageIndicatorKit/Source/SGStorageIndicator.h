//
//  SGStorageIndicator.h
//  StrorageIndicatorKit
//
//  Created by Simon Gaus on 07.04.20.
//  Copyright © 2020-2024 Simon Gaus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <StrorageIndicatorKit/SGStorageIndicatorDelegateProtocol.h>

/**

An interface that provides a visual representation of a storage confinguration.

*/

NS_ASSUME_NONNULL_BEGIN

@interface SGStorageIndicator : NSView
#pragma mark - Get and set the delegate
///---------------------------------------------------------
/// @name Get and set the delegate
///---------------------------------------------------------

/**
 @brief Get and set the delegate. The default value is 'nil'.
 */
@property (nullable, weak) id <SGStorageIndicatorDelegate> delegate;


#pragma mark - Reload the storage indicator
///----------------------------------------------------------------
/// @name Reload the storage indicator
///----------------------------------------------------------------

/**
 @brief Marks the soterage indicator as needing redisplay, so it will reload the data form the delegate and draw the new values.
 */
- (void)reloadData;


#pragma mark - Configurate the indicator
///-----------------------------------------------------------
/// @name Configurate the indicator
///-----------------------------------------------------------

/**
 @brief Boolean value indicating if the segment info popover should be displayed when the mouse hovers over a given segment. Defaults to YES.
 */
@property (nonatomic, readwrite) IBInspectable BOOL showSegmentIndicator;


#pragma mark - Appearance
///-----------------------------------
/// @name Appearance
///-----------------------------------

/**
 @brief The color used to fill the storage indicator.
 */
@property (nonatomic, strong) IBInspectable NSColor *fillColor;
/**
 @brief The color used to draw the storage indicators outline.
 */
@property (nonatomic, strong) IBInspectable NSColor *outlineColor;
/**
 @brief The color used to draw the storage indicator if the added segment capacities exceed the total capcity. Defaults to red.
 */
@property (nonatomic, strong) IBInspectable NSColor *warningColor;
/**
@brief The color used to draw the segment title. Defaults to textColor.
*/
@property (nonatomic, strong) NSColor *segmentTitleColor;
/**
@brief The x inset for the segment titles. Defaults to 10.0f.
*/
@property (nonatomic, readwrite) CGFloat segmentTitleInset;


@end

NS_ASSUME_NONNULL_END
