#import "BrowserDelegate.h"

@implementation BrowserDelegate
- (BrowserDelegate *) init
{
  self = [super init];

  browserColumns = [NSMutableArray new];

  return self;
}

- (id) initWithPagesDictionary: (NSMutableDictionary *) pagesDictionary
{
  if (!(self = [self init]))
  {
    return nil;
  }

  pages = RETAIN(pagesDictionary);

  return self;
}

- (void) replacePagesDictionary: (NSMutableDictionary *) pagesDictionary
{
  [browserColumns removeAllObjects];
  RELEASE(pages);

  pages = RETAIN(pagesDictionary);
}

- (void) dealloc
{
  RELEASE(pages);

  [super dealloc];
}

- (void) ensureDataLoaded: (NSBrowser *) sender column: (int) column
{
  NSDictionary *baseDict;

  // remove unused column data
  while (column < [browserColumns count])
  {
    // Autorelease data?
    [browserColumns removeLastObject];
  }

  if (column == 0)
  {
    // Retrieve dictionary directly
    baseDict = [pages objectForKey: @"0"];
  }
  else
  {
    // Get the selected cell's dictionary
    int parentColumn = column - 1;
    baseDict = [[[sender selectedCellInColumn: parentColumn] 
              representedObject] objectForKey: @"Children"];
  }

  [browserColumns addObject: [baseDict allValues]];
}

- (BOOL) browser: (NSBrowser *) sender isColumnValid: (int) column;
{
  if ([browserColumns count] > column)
  {
    return YES;
  }

  return NO;
}

- (int) browser: (NSBrowser *) sender numberOfRowsInColumn: (int) column
{
  int rows = 0;

  if (column == 0)
  {
    rows = [[pages objectForKey: @"0"] count];
  }
  else
  {
    int parentColumn = column - 1;
    NSDictionary *children;
    NSDictionary *parentDict = [[sender selectedCellInColumn: parentColumn]
        representedObject];

    children = [parentDict objectForKey: @"Children"];
    if (children != nil)
    {
      rows = [children count];
    }
  }

  return rows;
}

- (void) browser: (NSBrowser *) sender willDisplayCell: (id) cell
           atRow: (int) row column: (int) column
{
  NSDictionary *pageDict;
  NSDictionary *children;

  if (row == 0)
  {
    [self ensureDataLoaded: sender column: column];
  }

  pageDict = [[browserColumns objectAtIndex: column] 
                              objectAtIndex: row];
  children = [pageDict objectForKey: @"Children"];

  [cell setLeaf: children == nil || [children count] == 0 ? YES : NO];
  [cell setStringValue: [pageDict objectForKey: @"Subject"]];
  [cell setRepresentedObject: pageDict];
}

- (NSString *) description
{
  return @"BrowserDelegate";
}
@end
