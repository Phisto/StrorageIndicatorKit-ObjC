//
//  ViewController.m
//  StorageBarExample-ObjC
//
//  Created by Simon Gaus on 07.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

#import "ViewController.h"

#pragma mark - IMPLEMENTATION


@implementation ViewController
#pragma mark - View Controller Methodes

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.storageIndicator.delegate = self;
}

#pragma mark - Update Storage Indicator

- (IBAction)updateIndicator:(id)sender {
    
    [self.storageIndicator reloadData];
}

#pragma mark - Storage Indicator Methodes
 
- (NSInteger)numberOfSegments {
    return 4;
}

- (nonnull NSArray<NSNumber *> *)segmentSizes {
    unsigned long long multi = 1073741824;
    
    return @[@((unsigned long long)(self.otherSizeTextField.floatValue*multi)), @((unsigned long long)(self.musicSizeTextField.floatValue*multi)), @((unsigned long long)(self.audiobooksSizeTextField.floatValue*multi)), @((unsigned long long)(self.podcastSizeTextField.floatValue*multi))];
}

- (nonnull NSArray<NSString *> *)segmentTitles {
    return @[@"Sonstiges", @"Musik", @"Hörbücher", @"Podcasts"];
}

- (unsigned long long)totalCapcity {
    return (unsigned long long)(self.totalCapcityTextField.floatValue*1073741824);
}

- (NSArray<NSColor *> *)segmentColors {
    
    return @[[NSColor grayColor], [NSColor greenColor], [NSColor yellowColor], [NSColor brownColor]];
}

#pragma mark -
@end
