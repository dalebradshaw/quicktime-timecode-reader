//
//  NSString+Additions.h
//  ElementDrop
//


#import <Cocoa/Cocoa.h>


@interface NSString (SearchingAdditions)

- (BOOL)containsString:(NSString *)aString;
- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag;

@end
