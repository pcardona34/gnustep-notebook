#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>

#import <AppKit/NSBrowser.h>
#import <AppKit/NSBrowserCell.h>

@interface BrowserDelegate: NSObject
{
  NSMutableArray *browserColumns;
  NSMutableDictionary *pages;
}

- (id) initWithPagesDictionary: (NSMutableDictionary *) pagesDictionary;
- (void) replacePagesDictionary: (NSMutableDictionary *) pagesDictionary;

- (BOOL) browser: (NSBrowser *) sender isColumnValid: (int) column;
- (int)  browser: (NSBrowser *) sender numberOfRowsInColumn: (int) column;
- (void) browser: (NSBrowser *) sender willDisplayCell: (id) cell
           atRow: (int) row column: (int) column;
@end

/* vim:set ft=objc: */
