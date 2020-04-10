//
//  SGStorageIndicatorDelegateProtocol.h
//  StrorageIndicatorKit
//
//  Created by Simon Gaus on 07.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

@import Cocoa;

/**
 
 A set of methods that a storage indicator uses to provide data to a storage indicator and allow the editing of the storage indicator's appearance.
 
 ##Discussion
 The returned values will be cached and refresh only after calling the storage indicator's `-reloadData` method. The available capcity will be calculated by substracting all provided segment sizes from the total capicity. The storage indicator is able to handle a 'virtual' overflow of the storage capacity, which could be used to warn a user about an action that will not complete due to insufficient storage space.
 
 */

NS_ASSUME_NONNULL_BEGIN

@protocol SGStorageIndicatorDelegate <NSObject>
#pragma mark - Getting Values
///------------------------------------------
/// @name Getting Values
///------------------------------------------
@required

/**
 @brief The size of the storage device the storage indicator represents, in bytes.
 */
- (unsigned long long)totalCapcity;

/**
 @brief Returns the number of segments manged by the storage bar.
 @return The number of segments.
 */
- (NSInteger)numberOfSegments;

/**
 @brief Returns the size of each segment in an array, in bytes. The size should be unsigned long long NSNumber object.
 @return An array holding the segment sizes.
*/
- (NSArray<NSNumber *> *)segmentSizes;

/**
 @brief Returns the title of each segment in an array.
 @return An array holding the segment titles.
*/
- (NSArray<NSString *> *)segmentTitles;


#pragma mark - Change appearance
///----------------------------------------------
/// @name Change appearance
///----------------------------------------------
@optional

/**
 @brief Returns the title of the segment that represents the available space.
 @return The available space segment tile. Default is "Available".
*/
- (NSString *)availableSpaceSegmentTitle;

/**
 @brief Returns the title of the segment that is displayed if the totalCapcity is exceeded.
 @return The overflow segment tile. Default is "Too much".
*/
- (NSString *)overflowSegmentTitle;

/**
 @brief Returns the color of each segment in an array.
 @return An array holding the segment colors.
*/
- (NSArray<NSColor *> *)segmentColors;

/**
 @brief Returns the color of the segment that is displayed if the totalCapcity is exceeded.
 @return The overflow segment color. Default is the system red color.
*/
- (NSColor *)overflowSegmentColor;


@end

NS_ASSUME_NONNULL_END
