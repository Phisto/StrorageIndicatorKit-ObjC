//
//  SGSegmentViewController.h
//  StrorageIndicatorKit
//
//  Created by Simon Gaus on 08.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

@import Cocoa;

/**
 
 ...
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface SGSegmentViewController : NSViewController

@property (nonatomic, copy) NSString *segmentTitle;
@property (nonatomic, readwrite) unsigned long long capacity;

@end

NS_ASSUME_NONNULL_END
