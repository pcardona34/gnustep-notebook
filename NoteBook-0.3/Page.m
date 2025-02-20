#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>

#import <AppKit/AppKit.h>

#import "Page.h"
#import "PageNameController.h"

@implementation Page
- (id) init
{
  static NSPoint cascadePoint = {0.0, 0.0};
  self = [super init];

  if (![NSBundle loadNibNamed: @"Page" owner: self])
  {
    [self release];
    return nil;
  }

	if (NSEqualPoints (cascadePoint, NSZeroPoint)) {		/* First time through... */
		NSRect frame = [window frame];
		cascadePoint = NSMakePoint (frame.origin.x, NSMaxY (frame));
	}
	cascadePoint = [window cascadeTopLeftFromPoint: cascadePoint];
  [window setDelegate: self];

  [subject setDelegate: self];
  [keywords setDelegate: self];
  [body setDelegate: self];

  filename = nil;
  workingDocumentDirectory = NSHomeDirectory();

  return self;
}

- (id) initAsNew
{
  if (!(self = [self init]))
  {
    return nil;
  }

  store = RETAIN([self _createEmptyNotesDictionary]);

  keywordStore = RETAIN([store objectForKey: @"Keywords"]);
  pageStore = RETAIN([store objectForKey: @"Pages"]);

  browserDelegate = RETAIN([[BrowserDelegate alloc]
      initWithPagesDictionary: pageStore]);
  [browser setDelegate: browserDelegate];

  [self updateTitle];
  [window makeKeyAndOrderFront: nil];

  return self;
}

- (id) initWithPath: (NSString *) aFilename
{
  if (!(self = [self init]))
  {
    return nil;
  }

  filename = RETAIN(aFilename);
  [self readFromFile];

  browserDelegate = RETAIN([[BrowserDelegate alloc] 
      initWithPagesDictionary: pageStore]);
  [browser setDelegate: browserDelegate];

  [self updateTitle];
  [window makeKeyAndOrderFront: nil];

  return self;
}

- (void) readFromFile
{
  store = RETAIN([NSMutableDictionary
      dictionaryWithContentsOfFile: filename]);
  keywordStore = RETAIN([store objectForKey: @"Keywords"]);
  pageStore = RETAIN([store objectForKey: @"Pages"]);
}

- (void) dealloc
{
  RELEASE(browserDelegate);
  RELEASE(keywordStore);
  RELEASE(pageStore);
  RELEASE(store);

  [super dealloc];
}

+ (BOOL) openUntitledPage
{
  return [[self alloc] initAsNew] ? YES : NO;
}

+ (void) openWithPath: (NSString *) aFilename
{
  [[self alloc] initWithPath: aFilename];
}

+ (void) open: (id) sender
{
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setAllowsMultipleSelection: YES];
  [panel setDirectory: [Page workingDocumentDirectory]];

  if ([panel runModalForTypes: [NSArray arrayWithObject: @"notes"]])
  {
    NSArray *filenames = [panel filenames];
    unsigned cnt, numFiles = [filenames count];

    for (cnt = 0; cnt < numFiles; cnt++)
    {
      [Page openWithPath: [filenames objectAtIndex: cnt]];
    }
  }

}

- (NSMutableDictionary *) _createEmptyNotesDictionary
{
  NSMutableDictionary *kw, *pg, *base;

  kw = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    @"0", @"KeywordNextId",
    [NSMutableDictionary dictionary], @"KeywordList", nil];
  pg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    @"1", @"PageNextId",
    [NSMutableDictionary dictionary], @"0", nil];

  base = [NSMutableDictionary
      dictionaryWithObjectsAndKeys:
      kw, @"Keywords", pg, @"Pages", nil];

  return base;
}

- (void) triggerModified
{
  [window setDocumentEdited: YES];
}

- (void) clearModified
{
  [window setDocumentEdited: NO];
}

- (void) updateTitle
{
  NSString *title = [NSString stringWithFormat: @"%@",
      filename == nil ? @"Untitled" : [filename lastPathComponent]];
  [window setTitle: title];
}

- (NSString *) filename
{
  return filename;
}

+ (Page *) pageForWindow: (NSWindow *) aWindow
{
  id delegate = [aWindow delegate];

  if (delegate && [delegate isKindOfClass: [Page class]])
    return delegate;

  return nil;
}

+ (NSString *) workingDocumentDirectory
{
  Page *page = [Page pageForWindow: [NSApp mainWindow]];
  if (page)
  {
    return [[page filename] stringByDeletingLastPathComponent];
  }
  
  return NSHomeDirectory();
}

- (BOOL) isModified
{
  return [window isDocumentEdited];
}

- (void) newPage: (id) sender makeChild: (BOOL) makeChild
{
  int selectedColumn, selectedRow;
  int newId; 
  int idx, peerCount;

  NSMutableDictionary *newPage, *parentPage, *parentChildrenDict;
  NSString *pageName;
  NSString *newIdString;
  NSArray *peerPages;

  selectedColumn = [browser selectedColumn];
  selectedRow    = [browser selectedRowInColumn: selectedColumn];
  
  newId = [[pageStore objectForKey: @"PageNextId"] intValue];
  PageNameController *c = AUTORELEASE([PageNameController new]);
  [NSBundle loadNibNamed: @"PageName" owner: c];
  pageName = [c run];

  if (pageName == nil) 
    return;

  newIdString = [NSString stringWithFormat: @"%i", newId];
  newPage = [NSMutableDictionary dictionaryWithCapacity: 5];
  [newPage setObject: newIdString forKey: @"Id"]; 
  [newPage setObject: pageName forKey: @"Subject"];
  [newPage setObject: @"" forKey: @"Keywords"];
  [newPage setObject: @"" forKey: @"Body"];
  [newPage setObject: [NSMutableDictionary dictionary] forKey: @"Children"];

  if (makeChild)
  {
    NSBrowserCell *cell = [browser selectedCell];
    parentPage = [cell representedObject];
    parentChildrenDict = [parentPage objectForKey: @"Children"];
  }
  else
  {
    if (selectedColumn <= 0) // -1 when no selected column
    {
      parentPage = [pageStore objectForKey: @"0"];
      parentChildrenDict = parentPage;
      selectedColumn = 0; // In case -1, later we wish to treat it as col 0
    }
    else
    {
      NSBrowserCell *cell = [browser selectedCellInColumn: selectedColumn - 1];
      parentPage = [cell representedObject];
      parentChildrenDict = [parentPage objectForKey: @"Children"];
    }
  }

  [parentChildrenDict setObject: newPage forKey: newIdString];
  [pageStore setObject: [NSString stringWithFormat: @"%i", newId + 1]
                forKey: @"PageNextId"];

  [browser reloadColumn: selectedColumn];
  [browser selectRow: selectedRow inColumn: selectedColumn];

  peerPages = [parentChildrenDict allValues];
  peerCount = [peerPages count];
  for (idx = 0; idx < peerCount; idx++)
  {
    NSDictionary *obj = [peerPages objectAtIndex: idx];
    if ([newIdString isEqual: [obj objectForKey: @"Id"]])
    {
      int col = selectedColumn;
      if (makeChild)
      {
        col++;
      }

      [browser selectRow: idx inColumn: col];
      [self browserChanged: browser];
      [window makeFirstResponder: keywords];
    }
  }

  [self triggerModified];
}

- (void) newPage: (id) sender
{
  [self newPage: sender makeChild: NO];
}

- (void) newChildPage: (id) sender
{
  [self newPage: sender makeChild: YES];
}

- (void) deletePage: (id) sender
{
  NSBrowserCell *pageCell = [browser selectedCell];
  NSDictionary  *page = [pageCell representedObject];
  NSString *message = [NSString stringWithFormat: 
    @"Are you sure you wish to delete '%@'?", [page objectForKey: @"Subject"]];
  
  int retCode = NSRunAlertPanel(@"Confirmation", message, @"Yes", @"No", nil);

  if (retCode != NSOKButton)
  {
    return ;
  }

  NSMutableDictionary *parent;
  NSMutableDictionary *children;
  int selectedColumn = [browser selectedColumn];
  int selectedRow = -1;

  if (selectedColumn == 0)
  {
    parent = [pageStore objectForKey: @"0"];
    children = parent;
  }
  else
  {
    NSBrowserCell *parentCell = [browser selectedCellInColumn: 
      selectedColumn - 1];
    parent = [parentCell representedObject];
    selectedColumn--;

    selectedRow = [browser selectedRowInColumn: selectedColumn];
    children = [parent objectForKey: @"Children"];
  }

  if ([[page objectForKey: @"Children"] count] > 0)
  {
    if (NSRunAlertPanel(@"Warning", 
          @"All children will be removed also, continue?", 
          @"Yes", @"No", nil) != NSOKButton)
    {
      return ;
    }
  }

  [children removeObjectForKey: [page objectForKey: @"Id"]];

  [browser reloadColumn: selectedColumn];

  if (selectedRow >= 0)
  {
    [browser selectRow: selectedRow inColumn: selectedColumn];
  }
  
  [self triggerModified];
}

- (void) browserChanged: (NSBrowser *) sender
{
  NSCell *selectedCell = [sender selectedCell];
  NSDictionary *page = [selectedCell representedObject];
  NSData *data;

  [subject setStringValue: [page objectForKey: @"Subject"]];
  [keywords setStringValue: [page objectForKey: @"Keywords"]];

  data = [[page objectForKey: @"Body"]
           dataUsingEncoding: NSASCIIStringEncoding];
  [body replaceRange: NSMakeRange(0, [[body string] length])
             withRTF: data];
}

- (BOOL) validateMenuItem: (NSMenuItem *) anItem
{
  if (   [anItem action] == @selector(saveDocument:)
      || [anItem action] == @selector(revertDocumentToSaved:))
  {
    return [self isModified];
  }
  return YES;
}

- (BOOL) doSaveDocument: (BOOL) showPanel 
        makeCurrentFile: (BOOL) makeCurrentFile
      clearModifiedFlag: (BOOL) clearModifiedFlag
{
  NSString *writeToFilename = filename;

  if (filename == nil)
  {
    showPanel = YES;
  }
  
  if (showPanel)
  {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setRequiredFileType: @"notes"];
    [panel setDirectory: [Page workingDocumentDirectory]];

    if ([panel runModal])
    {
      writeToFilename = RETAIN([panel filename]);
    }
    else
    {
      writeToFilename = nil;
    }
  }

  if (writeToFilename != nil)
  {
    if ([self isModified])
    {
      // Update current page because w/o leaving the controls otherwise, the
      // actual store is not updated, therefore, your current page edits
      // will not be saved.
      [self updatePage: subject];
      [self updatePage: keywords];
      [self updatePage: body];
    }
    
    if (![store writeToFile: writeToFilename atomically: NO])
    {
      return NO;
    }

    if (makeCurrentFile)
    {
      filename = writeToFilename;
    }

    if (clearModifiedFlag)
    {
      [self clearModified];
    }

    [self updateTitle];

    return YES;
  }

  return NO;
}

- (BOOL) saveDocument
{
  if ([self isModified] == YES)
  {
    return [self doSaveDocument: NO makeCurrentFile: YES 
              clearModifiedFlag: YES];
  }

  return YES;
}

- (void) saveDocument: (id) sender
{
  if ([self isModified] == YES)
  {
    [self doSaveDocument: NO makeCurrentFile: YES clearModifiedFlag: YES];
  }
}

- (void) saveDocumentAs: (id) sender
{
  [self doSaveDocument: YES makeCurrentFile: YES clearModifiedFlag: YES];
}

- (void) saveDocumentTo: (id) sender
{
  [self doSaveDocument: YES makeCurrentFile: NO clearModifiedFlag: NO];
}

- (void) revertDocumentToSaved: (id) sender
{
  if (filename == nil)
  {
    NSRunAlertPanel(@"Warning",
        @"Document has never been saved, cannot revert", @"OK", nil, nil);
    return ;
  }

  if (NSRunAlertPanel(@"Revert to Saved",
        @"This will loose all current edits. Are you sure?", @"Cancel", 
        @"Revert", nil) == NSAlertDefaultReturn)
  {
    return ;
  }

  RELEASE(keywordStore);
  RELEASE(pageStore);
  RELEASE(store);

  [self readFromFile];

  [browserDelegate replacePagesDictionary: pageStore];
  [browser reloadColumn: 0];

  [subject setStringValue: @""];
  [keywords setStringValue: @""];
  [body setText: @""];
  
  [self clearModified];
}

- (void) close: (id) sender
{
  [window close];
}

- (BOOL) canClosePage
{
  if ([self isModified])
  {
    int result = NSRunAlertPanel(@"Close", @"Document has been edited. Save?",
        @"Save", @"Don't Save", @"Cancel");
    switch (result)
    {
      case NSAlertDefaultReturn: /* Save */
        if (![self saveDocument])
        {
          return NO;
        }
        break;

      case NSAlertOtherReturn: /* Cancel */
        return NO;
    }
  }

  return YES;
}

- (BOOL) windowShouldClose: (id) sender
{
  return [self canClosePage];
}

- (void) windowWillClose: (NSNotification *) notification
{
  [window setDelegate: nil];
  [self release];
}

- (void) updatePage: (id) control
{
  NSBrowserCell *cell = [browser selectedCell];
  NSMutableDictionary *page;
  NSString *key = nil;
  NSString *value = nil;

  if (cell == nil)
  {
    return ;
  }

  page = [cell representedObject];

  if (control == subject)
  {
    key = @"Subject";
    value = [subject stringValue];
  }
  else if (control == keywords)
  {
    key = @"Keywords";
    value = [keywords stringValue];
  }
  else if (control == body)
  {
    NSData *data = [body RTFFromRange: NSMakeRange(0, [[body string] length])];
    NSString *rtf = [[NSString alloc] initWithData: data 
                                          encoding: NSASCIIStringEncoding];
    
    key = @"Body";
    value = RETAIN(rtf);
    
    RELEASE(rtf);
  }

  if (key != nil && value != nil)
  {
    NSString *current = [page objectForKey: key];
    if (![current isEqual: value])
    {
      [self triggerModified];

      [page setObject: value forKey: key];
      [self updateTitle];

      if ([key isEqual: @"Subject"])
      {
        // Need to reload the column to show the changed value :-(
        // Seems like an overkill but not sure what else to do.
        int selectedColumn = [browser selectedColumn];
        int selectedRow = [browser selectedRowInColumn: selectedColumn];

        [browser reloadColumn: selectedColumn];
        [browser selectRow: selectedRow inColumn: selectedColumn];
      }
    }
  }
}

- (void) textDidBeginEditing: (NSNotification *) aNotification
{
  [self triggerModified];
}

- (void) textDidEndEditing: (NSNotification *) aNotification
{
  [self updatePage: [aNotification object]];
}

- (void) controlTextDidBeginEditing: (NSNotification *) aNotification
{
  [self triggerModified];
}

- (void) controlTextDidEndEditing: (NSNotification *) aNotification
{
  [self updatePage: [aNotification object]];
}

@end

