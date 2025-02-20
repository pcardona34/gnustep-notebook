#import <Foundation/NSObject.h>

@interface Controller : NSObject
{
}
- (void) createNew: (id)sender;
- (void) open: (id)sender;
- (BOOL) application: (NSApplication *) sender openFile: (NSString *) filename;
- (BOOL) applicationShouldTerminate: (NSApplication *) sender;
- (void) saveAll: (id)sender;
@end

/* vim:set ft=objc: */
