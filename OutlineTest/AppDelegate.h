//
//  AppDelegate.h
//  OutlineTest
//
//  Created by Petr Jodas on 16.05.13.
//  Copyright (c) 2013 Petr Jodas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>
{
  NSMutableArray *arrEXIF;
  NSMutableArray *arrIPTC;
  NSArray *fileTypes;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSOutlineView *outlineView;
- (IBAction)btnDisplayClicked:(id)sender;

@end
