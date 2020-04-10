//
//  ViewController.h
//  StorageBarExample-ObjC
//
//  Created by Simon Gaus on 07.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

@import Cocoa;

@import StrorageIndicatorKit;

@interface ViewController : NSViewController <SGStorageIndicatorDelegate>

@property (nonatomic, weak) IBOutlet SGStorageIndicator *storageIndicator;

@property (nonatomic, weak) IBOutlet NSTextField *otherSizeTextField;
@property (nonatomic, weak) IBOutlet NSTextField *musicSizeTextField;
@property (nonatomic, weak) IBOutlet NSTextField *audiobooksSizeTextField;
@property (nonatomic, weak) IBOutlet NSTextField *podcastSizeTextField;
@property (nonatomic, weak) IBOutlet NSTextField *totalCapcityTextField;

@end

