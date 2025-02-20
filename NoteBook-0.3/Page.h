#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>

#import <AppKit/NSBrowser.h>
#import <AppKit/NSMenu.h>

#import "BrowserDelegate.h"

@interface Page: NSObject
{
  // Controls
  id browser;
  id subject;
  id keywords;
  id body;

  // Others
  id window;

  // Internal data
  NSString *workingDocumentDirectory;
  BrowserDelegate *browserDelegate;
  NSString *filename;

  NSMutableDictionary *keywordStore;
  NSMutableDictionary *pageStore;
  NSMutableDictionary *store;
}

/* Creation Methods */
+ (BOOL) openUntitledPage;
+ (void) open: (id) sender;
+ (void) openWithPath: (NSString *) aFilename;
- (void) readFromFile;

/* Supporting Methods */
- (NSMutableDictionary *) _createEmptyNotesDictionary;
- (void) triggerModified;
- (void) updateTitle;
- (NSString *) filename;
+ (Page *) pageForWindow: (NSWindow *) aWindow;
+ (NSString *) workingDocumentDirectory;
- (BOOL) isModified;

/* Browser interaction methods */
- (void) browserChanged: (NSBrowser *) sender;

/* Page tree manipulation methods */
- (void) newPage: (id) sender makeChild: (BOOL) makeChild;
- (void) newPage: (id) sender;
- (void) newChildPage: (id) sender;
- (void) deletePage: (id) sender;

/* Document save methods */
- (BOOL) validateMenuItem: (NSMenuItem *) anItem;
- (BOOL) saveDocument;
- (void) saveDocument: (id) sender;
- (void) saveDocumentAs: (id) sender;
- (void) saveDocumentTo: (id) sender;
- (void) revertDocumentToSaved: (id) sender;
- (void) close: (id) sender;
- (BOOL) canClosePage;
- (BOOL) windowShouldClose: (id) sender;
- (void) windowWillClose: (NSNotification *) notification;

/* Automatic detection of page change/update methods */
- (void) updatePage: (id) control;
- (void) textDidBeginEditing: (NSNotification *) aNotification;
- (void) textDidEndEditing: (NSNotification *) aNotification;
- (void) controlTextDidBeginEditing: (NSNotification *) aNotification;
- (void) controlTextDidEndEditing: (NSNotification *) aNotification;
@end

/* vim:set ft=objc: */
