#import <AppKit/AppKit.h>
#import <AppKit/NSApplication.h>

#import "PageNameController.h"

@implementation PageNameController
- (void) awakeFromNib
{
  [window setDelegate: self];
  [window makeFirstResponder: pageName];
}

- (void) dealloc
{
  [window setDelegate: nil];
  DESTROY(window);
  [super dealloc];
}

- (NSString *) run
{
  if ([NSApp runModalForWindow: window] == NSOKButton)
    return [[pageName stringValue] retain];
  return nil;
}

- (void) cancelPress: (id) sender
{
  [NSApp stopModalWithCode: NSCancelButton];
}

- (void) okPress: (id) sender
{
  [NSApp stopModalWithCode: NSOKButton];
}
@end
