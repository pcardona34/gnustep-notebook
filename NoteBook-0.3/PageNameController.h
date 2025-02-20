#include <AppKit/AppKit.h>

@interface PageNameController : NSObject
{
  id pageName;
  id window;
  id okButton;
}

- (NSString *) run;
- (void) cancelPress: (id)sender;
- (void) okPress: (id)sender;
@end

/* vim:set ft=objc: */
