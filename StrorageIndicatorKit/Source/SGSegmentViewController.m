//
//  SGSegmentViewController.m
//  StrorageIndicatorKit
//
//  Created by Simon Gaus on 08.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

#import "SGSegmentViewController.h"

#pragma mark - CATEGORIES


@interface SGSegmentViewController (/* Private */)

@property (nonatomic, weak) IBOutlet NSTextField *segmentTitleLabel;
@property (nonatomic, weak) IBOutlet NSTextField *segmentCapacityLabel;

@end


#pragma mark - IMPLEMENTATION


@implementation SGSegmentViewController
#pragma mark - View COntroller Methodes

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.segmentTitleLabel.stringValue = self.segmentTitle;
    self.segmentCapacityLabel.stringValue = [NSByteCountFormatter stringFromByteCount:self.capacity countStyle:NSByteCountFormatterCountStyleFile];
}

#pragma mark -
@end
