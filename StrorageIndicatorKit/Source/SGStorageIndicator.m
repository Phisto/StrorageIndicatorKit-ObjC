//
//  SGStorageIndicator.m
//  StrorageIndicatorKit
//
//  Created by Simon Gaus on 07.04.20.
//  Copyright © 2020-2024 Simon Gaus. All rights reserved.
//

#import "SGStorageIndicator.h"

#import "SGSegmentViewController.h"

#import "NSString+SGWidthInView.h"

#pragma mark - TYPEDEFS

typedef unsigned long long looong;

#pragma mark - ENUMERATIONS


typedef NS_ENUM(NSInteger, SGSelectedSegmentKind) {
    SGSelectedSegmentNone = -1,
    SGSelectedSegmentAvailable = -2,
    SGSelectedSegmentTooMuch = -3
};


#pragma mark - CONSTANTS


static CGFloat const kCornerRadius = 5.0f;


#pragma mark - CATEGORIES


@interface SGStorageIndicator (/* Private */)

@property (nonatomic, readwrite) looong totalSize;
@property (nonatomic, readwrite) NSUInteger numberOfSegments;
@property (nonatomic, readwrite) NSArray<NSNumber *> *segmentSizes;
@property (nonatomic, readwrite) NSArray<NSString *> *segmentTitles;
@property (nonatomic, readwrite) NSArray<NSColor *> *segmentColors;

@property (nonatomic, readwrite) NSInteger currentMouseSegment;
@property (nonatomic, strong) SGSegmentViewController *popoverController;
@property (nonatomic, strong) NSPopover *segmentPopover;
@property (nonatomic, strong) NSString *availableSegmentTitle;
@property (nonatomic, strong) NSString *overflowSegmentTitle;
@property (nonatomic, strong) NSMutableArray<NSValue *> *visibleRects;

@end


#pragma mark - IMPLEMENTATION


@implementation SGStorageIndicator
#pragma mark - View Methodes

- (instancetype)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
        [self private_init];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    
    self = [super initWithFrame:frameRect];
    if (self) {
        [self private_init];
    }
    return self;
}

- (void)private_init {
    
    _totalSize = 1;
    _numberOfSegments = 1;
    _segmentSizes = @[@(1)];
    _segmentTitles = @[self.availableSegmentTitle];
    _segmentColors = @[self.fillColor];
    _currentMouseSegment = SGSelectedSegmentNone;
    _showSegmentIndicator = YES;
    _segmentTitleInset = 10.0f;
    
    [self configureTrackingArea];
    
    [self setNeedsUpdateConstraints:YES];
}

- (void)updateTrackingAreas {
    
    [self configureTrackingArea];
}

#pragma mark - Reload the storage indicator

- (void)reloadData {
    
    if (self.delegate != nil) {
        
        if ([self.delegate respondsToSelector:@selector(overflowSegmentTitle)]) {
            _overflowSegmentTitle = [self.delegate overflowSegmentTitle];
        }
        if ([self.delegate respondsToSelector:@selector(availableSpaceSegmentTitle)]) {
            _availableSegmentTitle = [self.delegate availableSpaceSegmentTitle];
        }
        if ([self.delegate respondsToSelector:@selector(overflowSegmentColor)]) {
            _warningColor = [self.delegate overflowSegmentColor];
        }
        
        looong providedCapacity = [self.delegate totalCapcity];
        NSInteger numberOfContentSegments = [self.delegate numberOfSegments];
        NSArray<NSNumber *> *contentSegmentSizes = [self.delegate segmentSizes];
        NSArray<NSString *> *contentSegmentTitles = [self.delegate segmentTitles];
        NSArray<NSColor *> *segmentColors = @[];
        if ([self.delegate respondsToSelector:@selector(segmentColors)]) {
            segmentColors = [self.delegate segmentColors];
        }
        looong sizeOfSegments = [self sizeFromSegments:contentSegmentSizes];
        
        _totalSize = (sizeOfSegments < providedCapacity) ? providedCapacity : sizeOfSegments+(sizeOfSegments-providedCapacity);
        _numberOfSegments = numberOfContentSegments+1;
        _segmentSizes = [contentSegmentSizes arrayByAddingObject:@((sizeOfSegments < providedCapacity) ? (providedCapacity-sizeOfSegments) : (sizeOfSegments-providedCapacity))];
        _segmentTitles = [contentSegmentTitles arrayByAddingObject:(sizeOfSegments < providedCapacity) ? self.availableSegmentTitle : self.overflowSegmentTitle];
        if (segmentColors.count != numberOfContentSegments) {
            NSMutableArray<NSColor *> *colors = [NSMutableArray arrayWithCapacity:_numberOfSegments];
            for (NSInteger i = 0; i < _numberOfSegments; i++) {
                [colors addObject:[NSColor colorWithRed:10.0f green:10.0f blue:10.0f*i alpha:1.0f]];
            }
            _segmentColors = colors;
        } else {
            _segmentColors = [segmentColors arrayByAddingObject:(sizeOfSegments < providedCapacity) ? self.fillColor : self.warningColor];
        }
        _currentMouseSegment = SGSelectedSegmentNone;
        
#warning Should we validate the input?
        
        [self setNeedsUpdateConstraints:YES];
        [self setNeedsLayout:YES];
        [self setNeedsDisplay:YES];
    }
    else {
        NSLog(@"Please configure a delegate for the progress indicator.");
    }
}

- (looong)sizeFromSegments:(NSArray<NSNumber *> *)sizes {
    
    looong capacityResult = 0;
    for (NSNumber *size in sizes) {
        capacityResult = capacityResult+size.unsignedLongLongValue;
    }
    return capacityResult;
}

#pragma mark - Drawing Methodes

- (void)drawRect:(NSRect)dirtyRect {
    
    [self drawBar:dirtyRect];
}

- (void)drawBar:(NSRect)frame {
    
    // inset the drawing because of the 1 pt border
    NSRect baseRect = NSMakeRect(NSMinX(frame)+0.5f, NSMinY(frame)+0.5f, floor(frame.size.width-0.5f), floor(frame.size.height-0.5f));
    
    [self drawSegments:baseRect];
    [self drawBackground:baseRect];
    [self drawLabels:baseRect];
}

- (void)drawBackground:(NSRect)frame {
    
    NSBezierPath* fillRectPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:kCornerRadius yRadius:kCornerRadius];
    [self.outlineColor setStroke];
    fillRectPath.lineWidth = 1;
    [fillRectPath stroke];
}

- (void)drawSegments:(NSRect)frame {
    
    NSMutableArray<NSValue *> *visibleRects = [NSMutableArray arrayWithCapacity:_numberOfSegments];
    NSMutableArray<NSBezierPath *> *paths   = [NSMutableArray arrayWithCapacity:_numberOfSegments];
    
    looong virtualCapacity                  =  _totalSize;
    CGFloat segmentMinX                     =  0.0f;
    CGFloat barMinX                         =  NSMinX(frame);
    CGFloat barMinY                         =  NSMinY(frame);
    CGFloat barHeight                       =  frame.size.height;
    CGFloat barWidth                        =  frame.size.width;
    
    for (int i = 0; i < _numberOfSegments; i++) {
        
        //          barMinX                      segmentMinX
        //          ↓                            ↓
        //          __________________________________________________________  ___
        //          |     segmentDrawingSize     | segmentSize   |           |   |
        // barMinY→ |____________________________|_______________|___________|  height
        //
        //                                       |-segmentWidth--|
        //          |--- segmentDrawingSize ---------------------|
        
        // get the segment width
        looong  segmentCapcity                          = _segmentSizes[i].unsignedLongLongValue;
        CGFloat             proportionalSegmentSize     = (CGFloat)segmentCapcity/(CGFloat)virtualCapacity;
         
        // get segment size
        CGFloat             segmentWidth                = proportionalSegmentSize*barWidth;
        CGSize              segmentSize                 = CGSizeMake(segmentWidth, barHeight);
    
        // get the segment drawing size
        CGFloat             segmentDrawingWidth         = segmentMinX+segmentWidth;
        CGSize              segmentDrawingSize          = CGSizeMake(segmentDrawingWidth, barHeight);
        
        // create rect and drawing rect
        NSRect visibleRect = NSMakeRect(segmentMinX,    barMinY,    segmentSize.width,          segmentSize.height);
        NSRect drawingRect = NSMakeRect(barMinX,        barMinY,    segmentDrawingSize.width,   segmentDrawingSize.height);
        
        // add to visible rects
        [visibleRects addObject:[NSValue valueWithRect:visibleRect]];
        
        // create darwing path
        [paths addObject:[self pathFromRect:drawingRect inFrame:frame]];
        
        // update the segments min x
        segmentMinX = segmentMinX + segmentWidth;
    }
     
    self.visibleRects = visibleRects;
    
    for (NSInteger i = paths.count; i > 0; i--) {
        
        NSColor *segmentColor = _segmentColors[i-1];
        NSBezierPath *pathToDraw = paths[i-1];
        [segmentColor setFill];
        [pathToDraw fill];
    }
}

- (void)drawLabels:(NSRect)frame {
    
    for (NSInteger i = 0; i < self.visibleRects.count; i++) {
        
        NSRect visibleRect = self.visibleRects[i].rectValue;
        NSString *title = self.segmentTitles[i];
        CGFloat titleWidth = [title widthWithPoints:13.0];
        if (visibleRect.size.width > titleWidth+(_segmentTitleInset*2.0f)) {

            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle alloc] init];
            textStyle.alignment = NSTextAlignmentLeft;
            NSDictionary* textFontAttributes = @{NSFontAttributeName: [NSFont systemFontOfSize: NSFont.systemFontSize], NSForegroundColorAttributeName: self.segmentTitleColor, NSParagraphStyleAttributeName: textStyle};
            CGFloat textTextHeight = [title boundingRectWithSize:visibleRect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:textFontAttributes].size.height;
            NSRect textTextRect = NSMakeRect(NSMinX(visibleRect)+10.0f, NSMinY(visibleRect) + (visibleRect.size.height - textTextHeight) / 2, visibleRect.size.width, textTextHeight);
            [NSGraphicsContext saveGraphicsState];
            NSRectClip(visibleRect);
            [title drawInRect:NSOffsetRect(textTextRect, 0, 1) withAttributes:textFontAttributes];
            [NSGraphicsContext restoreGraphicsState];
        }
    }
}

- (NSBezierPath *)pathFromRect:(NSRect)rect inFrame:(NSRect)frame {
    
    NSBezierPath *drawingPath;
    if (rect.size.width > 3.0f && rect.size.width < frame.size.width-3.0f) {
    
        NSRect progressFillRectInnerRect = NSInsetRect(rect, kCornerRadius, kCornerRadius);
        
        NSBezierPath* fillRectPath = [NSBezierPath bezierPath];
        [fillRectPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(progressFillRectInnerRect), NSMinY(progressFillRectInnerRect)) radius:kCornerRadius startAngle:180 endAngle:270];
        [fillRectPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
        [fillRectPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
        [fillRectPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(progressFillRectInnerRect), NSMaxY(progressFillRectInnerRect)) radius:kCornerRadius startAngle:90 endAngle:180];
        [fillRectPath closePath];
        drawingPath = fillRectPath;
    }
    else {
        drawingPath = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:kCornerRadius yRadius:kCornerRadius];
    }
    
    return drawingPath;
}

#pragma mark - Tracking Methdes

- (void)configureTrackingArea {
    
    NSTrackingArea *oldTrackingArea = self.trackingAreas.firstObject;
    if(oldTrackingArea) {
        [self removeTrackingArea:oldTrackingArea];
    }
    NSTrackingArea* newTrackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
    [self addTrackingArea:newTrackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    NSPoint mouseCenter = [self convertPoint:[event locationInWindow] fromView:nil];
    [self respondToMousePosition:mouseCenter];
}

- (void)mouseMoved:(NSEvent *)event {
    NSPoint mouseCenter = [self convertPoint:[event locationInWindow] fromView:nil];
    [self respondToMousePosition:mouseCenter];
}

- (void)respondToMousePosition:(NSPoint)position {
    
    if (!_showSegmentIndicator) {
        return;
    }
    
    NSInteger   selectedSegment     = SGSelectedSegmentAvailable;
    
    for (NSInteger i = 0; i < self.visibleRects.count; i++) {
  
        NSRect visibleRect = self.visibleRects[i].rectValue;
        if (position.x >= visibleRect.origin.x && position.x <= visibleRect.origin.x+visibleRect.size.width) {
            selectedSegment = i;
            break;
        }
    }
    
    if (selectedSegment >= 0 && _currentMouseSegment != selectedSegment) {
        
        NSString *title = self.segmentTitles[selectedSegment];
        looong capacity = self.segmentSizes[selectedSegment].longLongValue;
        NSSize popoverSize = NSMakeSize([title widthWithPoints:13.0]+20.0f, 49.0f);
        [self showPopoverInRect:self.visibleRects[selectedSegment].rectValue withSize:popoverSize title:title andCapacity:capacity];
        
        _currentMouseSegment = selectedSegment;
    }
}

- (void)showPopoverInRect:(NSRect)popoverRect withSize:(NSSize)popoverSize title:(NSString *)title andCapacity:(looong)capacity {
    
    [self.segmentPopover close];
    
    NSPopover *entryPopover = [[NSPopover alloc] init];
    [entryPopover setContentSize:popoverSize];
    [entryPopover setBehavior:NSPopoverBehaviorTransient];
    [entryPopover setAnimates:YES];
    [entryPopover setContentViewController:self.popoverController];
    
    self.popoverController.segmentTitle = title;
    self.popoverController.capacity = capacity;

    // Show popover
    [entryPopover showRelativeToRect:popoverRect
                              ofView:self
                       preferredEdge:NSMaxYEdge];
    
    self.segmentPopover = entryPopover;
}

- (void)mouseExited:(NSEvent *)event {
    [self.segmentPopover close];
    _currentMouseSegment = SGSelectedSegmentNone;
}

#pragma mark - Getter/Lazy

- (SGSegmentViewController *)popoverController {
    
    if (!_popoverController) {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"SegmentView" bundle:[NSBundle bundleForClass:self.class]];
        _popoverController = storyboard.instantiateInitialController;
    }
    return _popoverController;
}

- (NSColor *)outlineColor {
    
    if (!_outlineColor) {
        _outlineColor = [NSColor disabledControlTextColor];
    }
    return _outlineColor;
}

- (NSColor *)fillColor {
    
    if (!_fillColor) {
        _fillColor = [NSColor controlBackgroundColor];
    }
    return _fillColor;
}

- (NSColor *)warningColor {
    
    if (!_warningColor) {
        _warningColor = [NSColor redColor];
    }
    return _warningColor;
}

- (NSString *)availableSegmentTitle {
    
    if (!_availableSegmentTitle) {
        _availableSegmentTitle = @"Available";
    }
    return _availableSegmentTitle;
}

- (NSString *)overflowSegmentTitle {
    
    if (!_overflowSegmentTitle) {
        _overflowSegmentTitle = @"Too much";
    }
    return _overflowSegmentTitle;
}

- (NSColor *)segmentTitleColor {
    
    if (!_segmentTitleColor) {
        _segmentTitleColor = [NSColor textColor];
    }
    return _segmentTitleColor;
}

#pragma mark -
@end
