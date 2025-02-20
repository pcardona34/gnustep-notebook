#import <AppKit/NSApplication.h>
#import <AppKit/NSPanel.h>

#import "Controller.h"
#import "Page.h"

@implementation Controller
- (void) createNew: (id)sender
{
  [Page openUntitledPage];
}

- (void) open: (id)sender
{
  [Page open: sender];
}

- (BOOL) application: (NSApplication *) sender openFile: (NSString *) filename
{
  [Page openWithPath: filename];
  return YES; // TODO: dumb
}

- (BOOL) applicationShouldTerminate: (NSApplication *) sender
{
  NSArray  *windows = [sender windows];
  unsigned count = [windows count];
  BOOL needsSaving = NO;

  while (!needsSaving && count--)
  {
    NSWindow *window = [windows objectAtIndex: count];
    Page     *page = [Page pageForWindow: window];

    if (page && [page isModified])
    {
      needsSaving = YES;
    }
  }

  if (needsSaving)
  {
    int choice = NSRunAlertPanel(@"Quit", @"You have unsaved documents.",
        @"Cancel", @"Quit Anyway", @"Review Unsaved");
    
    switch (choice)
    {
      case NSAlertDefaultReturn: /* Cancel */
        NSLog(@"Cancelling Quit");
        return NO;

      case NSAlertOtherReturn: /* Review Unsaved */
        NSLog(@"Reviewing");
        count = [windows count];

        while (count--)
        {
          NSWindow *window = [windows objectAtIndex: count];
          Page     *page = [Page pageForWindow: window];

          if (page)
          {
            [window makeKeyAndOrderFront: nil];

            if (![page canClosePage])
            {
              return NO;
            }
          }
        }
        break;
    }
  }
  
  return YES;
}

- (void) saveAll: (id) sender
{
  NSArray *windows = [NSApp windows];
  unsigned count   = [windows count];

  while (count--)
  {
    NSWindow *window = [windows objectAtIndex: count];
    Page     *page   = [Page pageForWindow: window];

    if (page)
    {
      [page saveDocument: nil];
    }
  }
}
@end
