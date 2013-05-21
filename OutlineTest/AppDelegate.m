//
//  AppDelegate.m
//  OutlineTest
//
//  Created by Petr Jodas on 16.05.13.
//  Copyright (c) 2013 Petr Jodas. All rights reserved.
//

#import "AppDelegate.h"
#import <Quartz/Quartz.h>
#import <AppKit/AppKit.h>
#import "CProperties.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  fileTypes = [[NSArray alloc] initWithObjects:@"jpg", @"JPG", @"jpeg", @"JPEG", @"png", @"PNG", @"tiff", @"TIFF", nil];

  // datasource
  arrEXIF = [[NSMutableArray alloc] init];
  [_outlineView setDelegate:self];
  [_outlineView setDataSource:self];

  // Drag&Drop
  [_outlineView registerForDraggedTypes:[NSArray arrayWithObjects: NSStringPboardType, NSFilenamesPboardType, NSURLPboardType, nil]];
  [_outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
  [_outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}


// Drag&Drop
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
  return NSDragOperationEvery;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index
{
  NSPasteboard *pb = [info draggingPasteboard];
  BOOL accepted = NO;
  NSArray    *array;
  if (!accepted && (array = [pb propertyListForType:NSFilenamesPboardType])
      != NULL)
  {
    NSURL *fileURL = [NSURL URLFromPasteboard:pb];
    NSString *sExt = [fileURL pathExtension];
    for (NSString* item in fileTypes)
    {
      if ([item rangeOfString:sExt].location != NSNotFound)
      {
        accepted = YES;
        break;
      }
    }
    if (accepted)
    {
      [self loadData:fileURL];
    }
  }
  return accepted;
}


// NSOutlineView
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  CProperties *prop = item;
  if (prop == nil)
  {
    //item is nil when the outline view wants to inquire for root level items
    return [arrEXIF count];
  }
  if ([prop values] != nil)
    return [[prop values] count];
  return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if ([item isKindOfClass:[CProperties class]])
  {
    CProperties *prop = item;
    if ([prop values] != nil)
    {
      return YES;
    } else {
      return NO;
    }
  } else
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  CProperties *prop = item;
  if (prop == nil)
  { //item is nil when the outline view wants to inquire for root level items
    return [arrEXIF objectAtIndex:index];
  }
  if ([prop values] != nil)
  {
    return [[prop values] objectAtIndex:index];
  }
  return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
  if ([item isKindOfClass:[CProperties class]])
  {
    CProperties *prop = item;
    if ([[tableColumn identifier] isEqualToString:@"sKey"])
    {
      if ([prop values] != nil )
      {
        // ... then write something informative in the header (number of values)
        return [NSString stringWithFormat:@"%@ (%li values)",[prop sKey], [[item values] count]];
      }
      return [prop sKey]; // ...and, if we actually have a value, return the value
    } else {
      if ([prop values] == nil)
      {
        return [prop sValue]; // return value without children
      }
    }
  } else {
    if ([[tableColumn identifier] isEqualToString:@"sKey"])
      return item;
  }
  return nil;
}


- (void)loadData:(NSURL *)url
{
  [self exif:url];
  [_outlineView reloadData];
  [_window setTitle:[NSString stringWithFormat:@"EXIF Info - %@", [url path]]];
}

- (IBAction)btnDisplayClicked:(id)sender
{
  //[self exif:[NSURL fileURLWithPath:@"/Users/jodynek/Pictures/BYT 4.jpg"]];
  NSOpenPanel *panel;
  panel = [NSOpenPanel openPanel];
  [panel setFloatingPanel:YES];
  [panel setCanChooseDirectories:NO];
  [panel setCanChooseFiles:YES];
  [panel setAllowsMultipleSelection:NO];
  [panel setAllowedFileTypes:fileTypes];
  int i = (int)[panel runModal];
  if(i == NSOKButton)
  {
    [self loadData:[panel URL]];
  }
}

- (void)fillCustomArray:(NSArray *)inputArray
            outputArray:(NSMutableArray *)outputArray
{
  [outputArray removeAllObjects];
  for(NSString *key in inputArray)
  {
    CProperties *prop = [[CProperties alloc] init];
    NSString *value = [inputArray valueForKey:key];
    if (value != nil)
    {
      if ([value isKindOfClass:[NSArray class]])
      {
        NSArray *subArray = [[NSArray alloc] initWithArray:(NSArray *)value];
        for(NSString *subKey in subArray)
        {
          //NSLog(@"SUBobj: %@", subKey);
        }
        [prop setSKey:key];
        [prop setValues:subArray];
      } else {
        [prop setSKey:key];
        [prop setSValue:value];
        //NSLog(@"obj: %@, %@", key, value);
      }
    }
    [outputArray addObject:prop];
  }
}

- (NSArray*) exif : (NSURL *) url
{
  CGImageSourceRef source = CGImageSourceCreateWithURL( (__bridge CFURLRef) url,NULL);
  if (!source)
  {
    int response;
    NSAlert *alert = [NSAlert alertWithMessageText:@"Could not create image source !" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:nil
                        contextInfo:&response];
    NSLog(@"***Could not create image source ***");
    return nil;
  }
  //get all the metadata in the image
  NSDictionary *metadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
  //get all the metadata EXIF in the image
  NSArray *exif = [metadata valueForKey:@"{Exif}"];
  //NSLog(@"AnnotationProfil: Exif -> %@", exif);
  if (exif == nil)
  {
    int response;
    NSAlert *alert = [NSAlert alertWithMessageText:@"No EXIF information in image !" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:nil
                        contextInfo:&response];
  }
  [self fillCustomArray:exif outputArray:arrEXIF];
  
  //get all the metadata IPTC in the image
  NSArray *iptc = [metadata valueForKey:@"{IPTC}"];
  NSLog(@"AnnotationProfil: IPTC -> %@",iptc);
  return exif;
}

@end
